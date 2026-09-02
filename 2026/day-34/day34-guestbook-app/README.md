# Day 34 Guestbook App

A simple web application for practising a three-service Docker Compose stack.

- **Flask:** serves the website on port `5000`
- **MySQL:** permanently stores guestbook messages
- **Redis:** stores the page-visit counter

This project intentionally contains no Dockerfile or `docker-compose.yml`.
Create them yourself as part of the Day 34 task.

## Files

```text
day34-guestbook-app/
├── app.py
├── requirements.txt
├── .env.example
├── static/
│   └── style.css
└── templates/
    └── index.html
```

## Docker Compose hints

Your Compose stack should contain three services named `web`, `db`, and
`cache`. Pass the following environment values to the web service:

```env
DB_HOST=db
DB_USER=appuser
DB_PASSWORD=apppassword
DB_NAME=guestbook
REDIS_HOST=cache
REDIS_PORT=6379
```

The MySQL service must create a database named `guestbook` and a user whose
credentials match the values above. The app creates its `messages` table
automatically when it starts.
