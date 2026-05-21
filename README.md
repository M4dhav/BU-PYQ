# BU Scholar

BU Scholar is a comprehensive mobile companion application designed specifically for Bennett University students. While the current version focuses on previous year question papers, the app is being expanded to become a complete academic resource hub offering study materials, roadmaps, project resources, research papers, and much more. The intuitive interface makes it easy to find relevant content by course name, code, or description.


## Features

### Currently Implemented
- **Previous Year Question Papers**: Access end-semester, mid-semester, makeup, supplementary exams, and supplementary materials (e.g. NPTEL assignment solutions) for various courses
- **Intuitive Search System**: Find resources by course name, code, or description with support for multi-word searches
- **Modern UI Design**: Clean and responsive interface built with Flutter's Material Design 3
- **PDF Viewing**: Seamlessly view PDF documents directly within the app
- **Manifest-driven content**: A single `pyq-data.json` file describes every course and paper, served as raw content from the GitHub repository — no app release needed to publish new papers

### Planned Features
- **Academic Roadmaps**: Structured learning paths for different programs and specializations
- **Project Repository**: Sample projects and resources for course assignments
- **Research Paper Access**: Curated collection of research papers by faculty and students
- **Study Materials**: Notes, tutorials, and additional resources for courses
- **Campus Resources**: Information about university facilities and academic support services

## Technology Stack

- **Frontend**: Flutter 3.x with Material Design 3
- **Content delivery**: Public GitHub raw content (`raw.githubusercontent.com`) for the `pyq-data.json` manifest and individual PDFs — no authentication, no GitHub API rate limits
- **Data modeling**: `json_serializable` + `build_runner` for code-generated `fromJson`/`toJson`
- **PDF Handling**: Syncfusion Flutter PDF Viewer
- **State Management**: Flutter's built-in state management with StatefulWidgets
- **HTTP Client**: Dart's `http` package
- **Hosting**: Vercel (Flutter web build)

## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or later)
- Dart SDK (compatible with Flutter version)
- An IDE (Visual Studio Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/M4dhav/BU-PYQ.git
   cd BU-Scholar
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Generate model code (one-time after fresh clone, and any time you change a model class)
   ```bash
   dart run build_runner build
   ```

4. Run the application
   ```bash
   flutter run
   ```

## Project Structure

```
.
├── pyq-data.json              # Source of truth: every course and paper
├── pyqs/                      # Flat folder of PDFs named <course_num>-<paper_num>.pdf
├── build.yaml                 # Routes json_serializable output to lib/models/generated/
├── lib/
│   ├── main.dart              # Entry point, routes, theme
│   ├── home_page.dart         # Course list + search
│   ├── privacy_policy.dart    # Privacy policy screen
│   ├── models/
│   │   ├── course.dart        # Course model (JsonSerializable)
│   │   ├── paper.dart         # Paper model (JsonSerializable)
│   │   ├── pyq_data.dart      # Top-level wrapper
│   │   └── generated/         # build_runner output (*.g.dart)
│   ├── services/
│   │   └── pyq_data_service.dart  # Fetches pyq-data.json, builds PDF URLs
│   ├── widgets/
│   │   ├── course_card.dart
│   │   ├── paper_button.dart
│   │   ├── pdf_viewer.dart
│   │   ├── paper_tag.dart
│   │   └── tag_chip.dart
│   └── utils/
│       └── string_extensions.dart
└── web/
    ├── index.html, manifest.json, favicon.png, icons/
    ├── sitemap.xml, robots.txt
    └── _redirects             # SPA fallback for the host
```

## Data Model

There's no backend service. The app reads everything from two locations in the GitHub repo:

- **`pyq-data.json`** at the repo root — a single JSON document describing every course and paper.
- **`pyqs/`** at the repo root — a flat folder of PDFs, each named `<course_num>-<paper_num>.pdf` to match the `paper_id` field in the manifest.

At runtime, the app does one HTTP GET for the manifest from `raw.githubusercontent.com` on the `main` branch, then constructs direct raw URLs for each PDF on demand. Adding or updating papers is purely a matter of editing the JSON and adding files — no app release required. See [CONTRIBUTIONS.md](CONTRIBUTIONS.md) for the full schema and contribution flow.

## Contributing

Contributions are very welcome. The two most common types:

**Adding question papers** — please read [CONTRIBUTIONS.md](CONTRIBUTIONS.md). The short version: add an entry to `pyq-data.json` and drop the matching PDF in `pyqs/`, both in the same PR opened against the **`dev`** branch.

**Code changes**:

1. Fork the repository
2. Create your feature branch off `dev` (`git checkout -b feature/amazing-feature dev`)
3. Commit your changes
4. Push to your fork and open a PR against `dev`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Developed as a comprehensive companion app for Bennett University students
- Inspired by the need for a unified platform to access academic resources and guidance
- Designed to enhance the student experience by providing easy access to course materials, roadmaps, and other academic resources
- Built with Flutter for cross-platform compatibility and ease of deployment
- Created with the goal of fostering academic success and supporting the Bennett University community
