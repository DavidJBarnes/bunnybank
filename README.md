# BunnyBank

A full-stack application that helps parents teach children the value of money using a virtual currency system ("Bunny Bucks").

## Structure

```
bunnybank/
├── api/          # Python FastAPI backend + PostgreSQL
├── parent_app/   # Flutter web app for parents (mobile-first)
├── child_app/    # Flutter app for children (web + Android)
└── docker-compose.yml
```

## How It Works

- **Parents** register, manage children, set PINs, create payment reasons, and send Bunny Bucks.
- **Children** log in with their ID + PIN set by the parent, see their balance, and receive real-time "cha-ching" notifications when money arrives.

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (for PostgreSQL)
- [Flutter 3.24+](https://docs.flutter.dev/get-started/install)
- Python 3.12+ (or use the Docker API container)

### 1. Start PostgreSQL

```bash
docker compose up -d db
```

### 2. Start the API

```bash
cd api
pip install -r requirements.txt
DATABASE_URL="postgresql+asyncpg://bunnybank:bunnybank@localhost:5432/bunnybank" \
  JWT_SECRET="dev-secret" \
  python -m uvicorn app.main:app --host 0.0.0.0 --port 9000 --reload
```

Or with Docker:

```bash
docker compose up -d
```

### 3. Start the Parent App

```bash
cd parent_app
flutter pub get
flutter run -d web-server --web-port 5000
```

### 4. Start the Child App

```bash
cd child_app
flutter pub get
flutter run -d web-server --web-port 5001
```

## URLs (local dev)

| Service     | URL                          |
|-------------|------------------------------|
| Parent App  | http://localhost:5000        |
| Child App   | http://localhost:5001        |
| API         | http://localhost:9000        |
| API Docs    | http://localhost:9000/docs   |

## API Endpoints (all prefixed `/api/v1`)

### Auth (Parents)
- `POST /auth/register` — register with name, email, password
- `POST /auth/login` — login, returns JWT

### Children
- `GET /children` — list children for logged-in parent
- `POST /children` — add child (name, age, birthday, photo, PIN)
- `PUT /children/{id}` — update child details
- `DELETE /children/{id}` — delete child
- `PUT /children/{id}/pin` — set/update child PIN

### Payment Reasons
- `GET /reasons` — list reasons
- `POST /reasons` — create reason
- `PUT /reasons/{id}` — update reason
- `DELETE /reasons/{id}` — delete reason

### Send Money
- `POST /send-money` — send money to children, creates transactions, pushes notifications

### Child Auth
- `POST /child/login` — login with child ID + PIN
- `GET /child/balance` — current balance
- `GET /child/transactions` — recent transactions

## Tech Stack

| Layer          | Technology                    |
|----------------|-------------------------------|
| Backend        | Python, FastAPI, SQLAlchemy   |
| Database       | PostgreSQL 16                 |
| Real-time      | Firebase Cloud Messaging      |
| Parent App     | Flutter Web (mobile-first)    |
| Child App      | Flutter (Web + Android)       |
| Auth           | JWT (parents), PIN (children) |
| Containerization | Docker, docker-compose      |
| CI             | GitHub Actions                |
