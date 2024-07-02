# Flutter Todo App [ TodoMaster (TM) ]
A simple Todo application built with Flutter that integrates with a Django backend. This app includes features like user authentication, task management, profile management, and password management.

## Features

- **User Authentication**: Registration, Login, Email Verification.
- **User Profile Management**: View and Update Profile.
- **Password Management**: Change Password, Forgot Password, Reset Password.
- **Todo Task Management**: Create, Read, Update, Delete tasks.

## Prerequisites

- Flutter SDK
- Dart
- Andriod Studio
- Python 3
- Django
- Django REST Framework

## Getting Started

### Backend Setup

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/Pundit4Real/Todo.git
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
    python manage.py makemigrations
    ```
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
    git clone https://github.com/Pundit4Real/Flutter-Todo-App.git
    cd Flutter-Todo-App/todo_app
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
  - `POST /auth/register/`: Register a new user
  - `POST /auth/verify-email/`: Verify user email
  - `POST /auth/login/`: User login
  - `POST /auth/change-password/`: Change user password
  - `POST /auth/forgot-password/`: Send password reset email
  - `POST /auth/reset-password/`: Reset user password

- **User Profile URLs**:
  - `GET /auth/profile/`: Get user profile
  - `PUT /auth/update-profile/`: Update user profile

- **Task URLs**:
  - `GET /todo/tasks/`: List all tasks
  - `POST /todo/tasks/create/`: Create a new task
  - `GET /todo/tasks/{id}/`: Retrieve a task
  - `PUT /api/tasks/{id}/`: Update a task
  - `DELETE /todo/tasks/{id}/delete`: Delete a task

## Architectural Considerations

### Backend

1. **Django REST Framework**: 
   - We utilized Django REST Framework (DRF) to build a robust and scalable API. DRF provides easy serialization, viewsets,genericsViews and authentication mechanisms.

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

### App Ui [ Screenshots ]

#### App Home Screen

![Splash Screen](splash.jpg)

