# Flutter Todo App

A simple Todo application built with Flutter that integrates with a Django backend. This app includes features like user authentication, task management, profile management, and password management.

## Features

- **User Authentication**: Registration, Login, Email Verification.
- **User Profile Management**: View and Update Profile.
- **Password Management**: Change Password, Forgot Password, Reset Password.
- **Todo Task Management**: Create, Read, Update, Delete tasks.

## Prerequisites

- Flutter SDK
- Dart
- Python 3
- Django
- Django REST Framework

## Getting Started

### Backend Setup

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/flutter_todo_django.git
    cd flutter_todo_django/backend
    ```

2. **Create a Virtual Environment**:
    ```bash
    python -m venv env
    source env/bin/activate  # On Windows use `env\Scripts\activate`
    ```

3. **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

4. **Run Migrations**:
    ```bash
    python manage.py migrate
    ```

5. **Run the Server**:
    ```bash
    python manage.py runserver
    ```

### Frontend Setup

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/flutter_todo_django.git
    cd flutter_todo_django/frontend
    ```

2. **Get Dependencies**:
    ```bash
    flutter pub get
    ```

3. **Run the App**:
    ```bash
    flutter run
    ```

## API Endpoints

- **Auth URLs**:
  - `POST /api/register/`: Register a new user
  - `POST /api/verify-email/`: Verify user email
  - `POST /api/login/`: User login
  - `POST /api/change-password/`: Change user password
  - `POST /api/forgot-password/`: Send password reset email
  - `POST /api/reset-password/`: Reset user password

- **User Profile URLs**:
  - `GET /api/profile/`: Get user profile
  - `PUT /api/update-profile/`: Update user profile

- **Task URLs**:
  - `GET /api/tasks/`: List all tasks
  - `POST /api/tasks/`: Create a new task
  - `GET /api/tasks/{id}/`: Retrieve a task
  - `PUT /api/tasks/{id}/`: Update a task
  - `DELETE /api/tasks/{id}/`: Delete a task

## Architectural Considerations

### Backend

1. **Django REST Framework**: 
   - We utilized Django REST Framework (DRF) to build a robust and scalable API. DRF provides easy serialization, viewsets, and authentication mechanisms.

2. **Token-Based Authentication**:
   - Implemented using `rest_framework_simplejwt` to handle user authentication securely through JWT tokens.

3. **Modular Structure**:
   - Separated concerns by organizing the code into different Django apps (e.g., `authentication`, `tasks`) to ensure maintainability and scalability.

4. **Custom User Model**:
   - A custom user model was used to extend the default Django user functionalities, allowing for email verification and other custom fields.

### Frontend

1. **Flutter**:
   - Chosen for its cross-platform capabilities, allowing the app to run on both iOS and Android with a single codebase.

2. **Provider for State Management**:
   - Utilized the `provider` package for efficient state management across the application.

3. **Responsive UI**:
   - Designed to be responsive to different screen sizes and orientations, ensuring a good user experience on both tablets and smartphones.

4. **Reusable Components**:
   - Created reusable widgets for buttons, text fields, and other UI components to maintain a consistent look and feel across the app.

## Non-Functional Requirements

1. **Performance**:
   - Optimized API responses and ensured efficient database queries to minimize latency.
   - Used Flutter's efficient rendering engine to ensure smooth UI performance.

2. **Scalability**:
   - The backend is designed to handle an increasing number of users and tasks by following REST principles and using Django's scalable architecture.
   - The frontend is modular, allowing for easy addition of new features without major refactoring.

3. **Security**:
   - Implemented JWT for secure user authentication.
   - Ensured data protection by validating user inputs and using Django's built-in security features to prevent common vulnerabilities.

4. **Usability**:
   - Focused on a clean and intuitive UI design.
   - Ensured the app is easy to navigate and use, with clear prompts and error messages.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to the Django and Flutter communities for their excellent documentation and support.
