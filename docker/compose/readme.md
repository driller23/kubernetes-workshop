# run this setup:

Save all these files in the same directory.
Run:

```
docker-compose up --build in that directory.
```

## This will:

Build your Flask app image
Start a PostgreSQL container
Initialize the database with the init.sql script
Start your Flask app, connecting it to the PostgreSQL database

Your Flask app will be accessible at http://localhost:5000, and you can test the database connection by visiting http://localhost:5000/users.
The PostgreSQL data will persist in a Docker volume named postgres_data, and your app code is mounted as a volume, allowing you to make changes without rebuilding the image.
