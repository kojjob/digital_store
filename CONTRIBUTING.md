# Contributing to DigitalStore

Thank you for your interest in contributing to DigitalStore! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Commit Guidelines](#commit-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Testing](#testing)
8. [Documentation](#documentation)
9. [Feature Requests and Bug Reports](#feature-requests-and-bug-reports)
10. [Community](#community)

## Code of Conduct

Our project adheres to a code of conduct that promotes a welcoming and inclusive environment. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

## Getting Started

Before you start contributing, make sure you have:

1. Read the [README.md](README.md) file
2. Set up the development environment following [GETTING_STARTED.md](GETTING_STARTED.md)
3. Familiarized yourself with the codebase using [DOCUMENTATION.md](DOCUMENTATION.md)

### For First-Time Contributors

If this is your first contribution, we recommend starting with issues labeled "good first issue" or "beginner friendly."

## Development Workflow

We follow a feature branch workflow:

1. **Fork the Repository** (if you're an external contributor)
2. **Create a Feature Branch** from the `develop` branch
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```
3. **Develop Your Feature**
   - Make changes in small, logical commits
   - Keep your branch updated with the latest changes from `develop`
     ```bash
     git checkout develop
     git pull origin develop
     git checkout feature/your-feature-name
     git rebase develop
     ```
4. **Push Your Branch**
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Create a Pull Request** from your feature branch to the `develop` branch

## Coding Standards

### Ruby/Rails

We follow the [Rails Community Style Guide](https://rails.rubystyle.guide/) with some modifications:

- Use 2 spaces for indentation
- Use snake_case for methods and variables
- Use CamelCase for classes and modules
- Avoid trailing whitespace
- End each file with a newline

We use RuboCop to enforce these standards:

```bash
bundle exec rubocop
```

### JavaScript/Stimulus

We follow a style guide based on the [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript):

- Use 2 spaces for indentation
- Use camelCase for variables and functions
- Use PascalCase for classes
- Use meaningful and descriptive names

### HTML/ERB and CSS

- Use 2 spaces for indentation
- Keep markup semantic
- Follow BEM naming convention for custom CSS
- Prefer TailwindCSS utility classes when possible

## Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/) for our commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types include:
- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation changes
- **style**: Changes that do not affect the meaning of the code (formatting, etc.)
- **refactor**: Code changes that neither fix a bug nor add a feature
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **chore**: Changes to the build process or auxiliary tools

Examples:
- `feat(auth): add session timeout feature`
- `fix: correct credit card validation`
- `docs: update installation instructions`

## Pull Request Process

1. **Open a PR to the `develop` branch**
2. **Fill out the PR template** with:
   - A clear description of the changes
   - Links to any related issues
   - Screenshots if applicable
   - Details on how to test the changes
3. **Request reviews** from appropriate team members
4. **Address review feedback** promptly
5. **Pass all CI checks** (tests, linting, security scans)
6. **Wait for approval** from at least one maintainer
7. **Merge using squash merge** (maintainers will do this)

## Testing

All new features and bug fixes should include appropriate tests:

- **Model tests** for business logic
- **Controller tests** for request handling
- **System tests** for user interactions
- **JavaScript tests** for Stimulus controllers

Run tests before submitting a PR:

```bash
rails test
```

### Test Coverage

We aim for high test coverage. If you're adding new code, please include tests that cover your changes.

## Documentation

Documentation is a crucial part of the project:

1. **Code Documentation**
   - Add comments for complex logic
   - Document public methods with descriptive comments
   - Update relevant sections in DOCUMENTATION.md

2. **User Documentation**
   - Update the README.md when changing user-facing features
   - Add or update help articles if applicable

3. **Technical Documentation**
   - Update DOCUMENTATION.md with architectural changes
   - Document new components and features

## Feature Requests and Bug Reports

### Feature Requests

When requesting a feature:
1. Check existing issues to avoid duplicates
2. Clearly describe the feature and its value
3. Provide details on expected behavior
4. Consider implementation challenges

### Bug Reports

When reporting a bug:
1. Check existing issues to avoid duplicates
2. Describe the bug in detail
3. Provide steps to reproduce
4. Include expected vs. actual behavior
5. Add screenshots if applicable
6. Specify your environment (browser, OS, etc.)

## Community

### Communication Channels

- **Issues**: For bug reports and feature discussions
- **Pull Requests**: For code review discussions
- **Project Management Board**: For tracking work progress

### Recognition

We value all contributions, from code to documentation to issue reporting. Contributors will be acknowledged in release notes and the project's contributors list.

### Becoming a Maintainer

Active contributors may be invited to become maintainers. This role includes:
- Reviewing and merging pull requests
- Triaging issues
- Guiding project direction
- Mentoring new contributors

## Thank You!

Your contributions help make DigitalStore better for everyone. We appreciate your time and effort in improving this project.
