# Redmine Subnavigation Plugin

![Version](https://img.shields.io/badge/version-0.3.15-blue.svg)
![Redmine](https://img.shields.io/badge/Redmine-5.0%20%7C%206.0-red.svg?logo=redmine)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**A powerful, collapsible sidebar navigation tree for Redmine.**

Transform your Redmine experience with a clean, hierarchical view of your Projects, Wiki pages, and Wiki Headings. Designed for productivity and ease of use.

---

## 🚀 Features

- **📂 Project Hierarchy**: Navigate smoothly through projects and subprojects.
- **📄 Wiki Tree**: Visual tree structure for all wiki pages.
- **¶ Wiki Headings**: Automatic Table of Contents (h1, h2, etc.) for the current page.
- **⚡ Collapsible Sidebar**: Toggle the sidebar to maximize your workspace.
- **🚫 Hide Breadcrumbs**: Optional setting to hide the Redmine breadcrumb trail for a cleaner look.
- **📌 Sticky Top Menu**: Optional setting to keep the main Redmine menu fixed at the top while scrolling.
- **🔄 Cascading Activation**: Automatically enables/disables the subnavigation module in subprojects when changed in a parent project (in 'Full Hierarchy' mode).
- **🎨 Modern Design**: Clean CSS that integrates seamlessly with modern Redmine themes.
- **🌍 Localized**: Available in English and German.
- **📱 Responsive**: Optimized for various screen sizes.

## 📸 Screenshots

| Wiki & Headers | Project Hierarchy |
|:---:|:---:|
| *(Add screenshot here)* | *(Add screenshot here)* |

## 📦 Installation

> [!IMPORTANT]
> The plugin directory **MUST** be named `redmine_subnavigation` for assets to load correctly.

1.  **Clone the repository** into your plugins directory:
    ```bash
    cd /path/to/redmine/plugins
    git clone https://github.com/modoq/redmine_subnavigation.git redmine_subnavigation
    ```

2.  **Install dependencies & assets**:
    ```bash
    bundle install
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production
    ```
    *Note: This step copies the required CSS/JS assets to the public directory.*

3.  **Restart Redmine**.

## ✅ Compatibility

| Plugin Version | Redmine Version | Ruby Version |
|:--------------:|:---------------:|:------------:|
| **0.2.x**      | 5.0+, 6.0+      | 3.0+         |

## ⚙️ Configuration

Navigate to **Administration > Plugins > Subnavigation > Configure**.

| Option | Description |
|:---|:---|
| **Sidebar Mode** | |
| *Disabled* | Plugin is inactive. |
| *Wiki & Headings* | Sidebar shows Wiki pages and headings only. |
| *Full Hierarchy* | Sidebar shows Projects, Wiki pages, and headings. **Enables cascading module activation.** |
| **Header Max Depth** | Maximum depth of headings (h1, h2, h3) to show in the TOC. |
| **Hide Breadcrumb** | Hides the default Redmine breadcrumb trail (e.g., `Project > Wiki > Page`) for a cleaner header. |
| **Sticky Top Menu** | Fixes the black top menu bar to the top of the screen when scrolling. |

> [!NOTE]
> **Cascading Activation**: When "Full Hierarchy" (`project_wiki`) mode is enabled, enabling or disabling the **Subnavigation** module in a project's settings will automatically apply the same change to all its subprojects.

## 🤝 Contributing

Contributions are welcome! Please fork the repository and submit a Pull Request.

1.  Fork it
2.  Create your feature branch (`git checkout -b feature/my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin feature/my-new-feature`)
5.  Create a new Pull Request

## 📄 License

This plugin is open source software licensed under the [MIT license](LICENSE).
