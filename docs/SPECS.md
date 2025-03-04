# Packwerk Backporting Specifications

## Overview

This document provides an overview of the specifications for backporting Packwerk from Rails 5 to Rails 3.2. The project has already undergone several backporting steps, including:

1. Rails 7 alpha → Rails 5.x
2. Ruby 3 → Ruby 2.3.8
3. Dockerization for compatibility with M-series Macs

These specifications detail the process, challenges, and solutions implemented during the backporting process, as well as providing guidelines for development in the backported environment.

## Table of Contents

| Specification | Description |
|---------------|-------------|
| [Backport Summary](specs/backport_summary.md) | High-level summary of backporting approach and key challenges |
| [Backport Implementation Plan](specs/backport_implementation_plan.md) | Step-by-step plan for implementing the backport |
| [Rails Backporting Strategy](specs/rails_backporting_strategy.md) | Overview of the approach to backporting from Rails 5 to Rails 3.2 |
| [Ruby Compatibility](specs/ruby_compatibility.md) | Modifications needed for Ruby 2.3.8 compatibility |
| [Docker Environment](specs/docker_environment.md) | Docker setup for local development |
| [Development Setup](specs/development_setup.md) | How to set up and run the project locally |
| [Testing Process](specs/testing_process.md) | How to run tests in the backported environment |
| [Dependency Management](specs/dependency_management.md) | Managing gem dependencies for Rails 3.2 compatibility |
| [Sorbet Compatibility](specs/sorbet_compatibility.md) | Handling Sorbet in the backported environment |
| [Known Issues and Workarounds](specs/known_issues.md) | Common issues and their solutions |
| [Backport Implementation Details](specs/backport_implementation.md) | Technical details on how specific backporting was implemented |

## Contributing

When contributing to this backported project, please ensure you've read the relevant specifications and follow the guidelines presented in the [Development Setup](specs/development_setup.md) document. 

## Implementation Process

For developers working on the backporting effort, we recommend following this process:

1. Read the [Backport Summary](specs/backport_summary.md) to understand the high-level approach
2. Review the [Backport Implementation Plan](specs/backport_implementation_plan.md) for the step-by-step implementation process
3. Consult the detailed technical specifications as needed during implementation
4. Follow the testing process outlined in [Testing Process](specs/testing_process.md)
5. Document all changes and issues discovered during implementation 