module RedmineSubnavigation
  module WikiSidebarHelper
    
    def render_sidebar_navigation(project, mode)
      return '' if mode == 'none'
      
      if mode == 'project_wiki'
        # Render project tree hierarchy containing the current project
        render_project_tree(project)
      else
        # Default: Just the wiki tree for current project
        render_wiki_sidebar_tree(project)
      end
    end

    # Renders the wiki page tree for a single project
    def render_wiki_sidebar_tree(project)
      return '' unless project.wiki

      pages = project.wiki.pages.includes(:content).order(:title).to_a
      return '' if pages.empty?

      # Group by parent_id to build tree
      pages_by_parent = pages.group_by(&:parent_id)
      root_pages = pages_by_parent[nil] || []

      return '' if root_pages.empty?

      render_tree(root_pages, pages_by_parent)
    end

    private
    
    # Renders project hierarchy up to root
    def render_project_tree(current_project)
        # Get root project
        root = current_project.root
        
        # We need to render the tree starting from root
        # Ideally we only render the branches relevant to the current project context or all visible?
        # User said "levels above for nested projects".
        # Let's render the full tree of the Root Project's descendants.
        
        # Get all descendants visible to user
        # This might be heavy if there are thousands. Assuming RedmineMini context -> manageable.
        projects = [root] + root.descendants.visible.to_a
        
        # Build hierarchy
        html = '<ul>'
        html << render_project_node(root, current_project)
        html << '</ul>'
        html
    end
    
    def render_project_node(project, current_active_project)
       html = '<li class="' 
       html << ' expanded' if project.is_ancestor_of?(current_active_project) || project == current_active_project
       html << '">'
       
       # Project Link
       is_active = project == current_active_project
       # Using a class to style it distinctively?
       # Use smart_project_path helper
       html << link_to(project.name, smart_project_path(project), class: "wiki-page-link type-project #{is_active ? 'project-active' : ''}")
       
       # If this is the active project, render its Wiki Tree below (if it has a wiki)
       # UPDATE: User wants to see expand icon if wiki exists, even if not active.
       # So we render the tree (hidden by CSS if not expanded via parent LI)
       if project.module_enabled?(:wiki) && User.current.allowed_to?(:view_wiki_pages, project)
           wiki_html = render_wiki_sidebar_tree(project)
           unless wiki_html.empty?
               html << wiki_html
           end
       end
       
       # Render Children
       children = project.children.visible.to_a
       if children.any?
           html << '<ul>'
           children.each do |child|
               html << render_project_node(child, current_active_project)
           end
           html << '</ul>'
       end
       
       html << '</li>'
       html
    end

    def render_tree(pages, pages_by_parent)
      html = '<ul>'
      pages.each do |page|
        html << '<li>'
        html << link_to_page(page)
        html << render_headers(page)
        
        children = pages_by_parent[page.id]
        if children
          html << render_tree(children, pages_by_parent)
        end
        html << '</li>'
      end
      html << '</ul>'
      html
    end

    def link_to_page(page)
      display_title = get_display_title(page)
      
      # Basic link, improvements like "active" class can be handled by JS matching URL
      "<a href=\"#{Rails.application.routes.url_helpers.project_wiki_page_path(page.project, page.title)}\" class=\"wiki-page-link type-page\" data-title=\"#{page.title}\">#{display_title}</a>"
    end

    def render_headers(page)
      return '' unless page.content
      
      text = page.content.text
      # Get max depth from settings, default to 3
      max_depth = (Setting.plugin_redmine_subnavigation['header_max_depth'] || 3).to_i
      
      headers = []
      
      # Regex for Markdown (## Header)
      # We capture: level (hashes), text
      # We iterate line by line or scan the whole text? 
      # Scan is easier but we need position to sort if we mix markdown/textile (rare but possible).
      # Let's map indexes to sort them correctly if mixed.
      
      # Markdown: # to #####
      text.scan(/^(\#{1,5})\s+(.+)$/).each do |match|
        level = match[0].length
        title = match[1].strip
        next if level > max_depth
        headers << { level: level, title: title, offset: Regexp.last_match.begin(0) }
      end
      
      # Textile: h1. to h5.
      text.scan(/^h([1-5])\.\s+(.+)$/).each do |match|
        level = match[0].to_i
        title = match[1].strip
        next if level > max_depth
        headers << { level: level, title: title, offset: Regexp.last_match.begin(0) }
      end

      # Sort by occurrence in text
      headers.sort_by! { |h| h[:offset] }
      
      return '' if headers.empty?

      # Filter out first header if it matches the page display title
      display_title = get_display_title(page)
      if headers.first[:title] == display_title
        headers.shift
      end
      
      return '' if headers.empty?

      html = '<ul class="wiki-page-headers">'
      
      # Track seen anchors to handle duplicates
      seen_anchors = Hash.new(0)

      headers.each do |h|
        header = h[:title]
        level = h[:level]
        
        base_anchor = header.parameterize
        if seen_anchors.key?(base_anchor)
          count = seen_anchors[base_anchor] += 1
          anchor = "#{base_anchor}-#{count}"
        else
          seen_anchors[base_anchor] = 0
          anchor = base_anchor
        end

        html << "<li><a href=\"#{Rails.application.routes.url_helpers.project_wiki_page_path(page.project, page.title, anchor: anchor)}\" class=\"wiki-header-link wiki-header-h#{level}\" data-anchor=\"#{anchor}\" data-header-text=\"#{header}\">#{header}</a></li>"
      end
      html << '</ul>'
      html
    end

    private

    def get_display_title(page)
      display_title = page.pretty_title
      if page.content
        # Try to find a H1 in text
        # Markdown: # Header or #Header
        if match = page.content.text.match(/^#\s+(.+)$/)
          display_title = match[1].strip
        # Textile: h1. Header
        elsif match = page.content.text.match(/^h1\.\s+(.+)$/)
          display_title = match[1].strip
        end
      end
      display_title
    end

    # Smart path tailored to user request:
    # 1. Overview (standard)
    # 2. Activity (if Overview not present/wanted - hard to detect, but we assume project_path handles redirects or we check permissions?)
    #    Actually Redmine's project_path IS the overview. 
    #    If the user has NO permission for overview (unlikely) or module is hidden...
    # We will try to rely on Redmine's default. 
    # But if we want to be explicit about Priority:
    # If standard project_path results in 403 or 404, we can't know here.
    # We will stick to project_path as primary. 
    # However, if we want to support "Activity as fallback", we'd need to check if user can view overview.
    # allowed_to?(:view_project, project) usually covers Overview.
    
    def smart_project_path(project)
      # Check if user has permission to see the project (Overview)
      if User.current.allowed_to?(:view_project, project)
         return project_path(project)
      end

      # Fallbacks if Overview is technically accessible but "empty"? (Can't check easily)
      # Or if user just lacks permission for Overview but has others? (Rare config)
      
      # 2. Activity
      if project.module_enabled?(:activity) # Activity module always exists? It's a pseudo-module often.
         return project_activity_path(project)
      end
      
      # 3. Issues
      if project.module_enabled?(:issue_tracking) && User.current.allowed_to?(:view_issues, project)
         return project_issues_path(project)
      end
      
      # 4. Wiki
      if project.module_enabled?(:wiki) && User.current.allowed_to?(:view_wiki_pages, project)
         return project_wiki_path(project)
      end
      
      # Default
      project_path(project)
    end
  end
end
