# iOS User Directory Application

## Project Overview

This iOS application follows a Clean, modular architecture pattern to create a user directory that fetches data from an external API, provides caching capabilities, and delivers a seamless user experience even in offline scenarios.

## Architecture

The project implements the Clean Architecture pattern with a clean separation of concerns:

- **Model**: Data structures representing the domain entities
- **View**: UI components rendered on screen
- **ViewModel**: Business logic and state management using `@MainActor`
- **Coordinator**: Navigation flow management between screens

## Key Features

- Modern Swift concurrency with async/await
- Robust error handling with meaningful user feedback
- Offline support with connectivity monitoring
- Data caching for improved performance and offline access
- Infinite scrolling user list with pull-to-refresh functionality
- Detailed user information screen
- Clean, modular code organization following SOLID principles

## Project Structure

```
📦 RandomusersApp
├── 📂 App
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppCoordinator.swift
│
├── 📂 Presentation
│   ├── 📂 UsersList
│   │   ├── UsersListViewController.swift
│   │   ├── UsersListViewModel.swift
│   │   └── UserCell.swift
│   │
│   └── 📂 UserDetail
│       ├── UserDetailViewController.swift
│       └── UserDetailViewModel.swift
│
├── 📂 Domain
│   ├── 📂 Models
│   │   └── User.swift
│   │
│   ├── 📂 UseCases
│   │   └── FetchUsersUseCase.swift
│   │
│   └── 📂 Protocols
│       └── UserRepositoryProtocol.swift
│
├── 📂 Data
│   ├── NetworkService.swift
│   │
│   ├── 📂 Repositories
│   │   └── UserRepository.swift
│   │
│   ├── 📂 DataSources
│   │   ├── 📂 Remote
│   │   │   └── UserRemoteDataSource.swift
│   │   │
│   │   └── 📂 Local
│   │       └── UserLocalDataSource.swift
│   │
│   └── 📂 Cache
│       └── UserCacheManager.swift
│
└── 📂 Common
    ├── 📂 Extensions
    └── 📂 Utils
        ├── NetworkMonitor.swift
        └── ErrorHandler.swift
```

## Implementation Details

### Modern Concurrency

The app leverages Swift's modern concurrency features:
- Async/await pattern for asynchronous operations
- Actors for thread-safe access to shared mutable state
- `@MainActor` annotation for view models to ensure UI updates on the main thread

### Data Flow

1. The app attempts to fetch user data from the [randomuser.me](https://randomuser.me/api/?results=10) API
2. Successfully fetched data is cached locally
3. If network is unavailable, the app serves cached data
4. Clear error messages are displayed when both network and cache are unavailable

### Network Layer

- `NetworkService`: Handles API requests with proper error handling
- `NetworkMonitor`: Tracks network connectivity changes and notifies the app
- Automatic fallback to cached data when network is unavailable

### UI Features

- Infinite scrolling implementation for the user list
- Pull-to-refresh functionality to fetch the latest data
- Loading indicators during network operations
- Error states with retry options
- Offline mode indicator when network is unavailable

### SOLID Principles Application

- **Single Responsibility**: Each class has a focused purpose
- **Open/Closed**: Components are designed for extension, not modification
- **Liskov Substitution**: Protocols enable interchangeable implementations
- **Interface Segregation**: Minimalist interfaces tailored to specific needs
- **Dependency Inversion**: Dependencies are based on abstractions, not concrete implementations

## Getting Started

1. Clone the repository
2. Open the project in Xcode 16.0 or later
3. Build and run on iOS 16.0+ device or simulator
