FROM python:3.10-slim

WORKDIR /usr/src/app

# set environment variables for non-interactive commands
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install Flask
RUN pip install Flask

# copy the application code into the container
COPY app.py .

# expose the application port
EXPOSE 8080

# run the application
CMD [ "python", "app.py" ]