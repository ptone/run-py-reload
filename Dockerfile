FROM python:3-slim

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY ./requirements.txt .
RUN pip install -r requirements.txt


## Production:
# CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app

## Dev:
CMD python app.py
COPY . .