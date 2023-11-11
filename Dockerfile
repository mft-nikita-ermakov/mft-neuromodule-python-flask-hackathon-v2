# Defines the base image that will be used to create a new image
FROM python:3.8.16-slim-bullseye AS builder

# Installs the necessary dependencies to run the Flash application
RUN pip install flask
RUN pip install flask-cors
RUN pip install flask-restful
RUN pip install ultralytics
RUN pip install Pillow
RUN pip install openpyxl

# Copies the poetry.lock and py project.tool files to the container
# Installs Poetry package manager and exports dependencies to a file requirements.txt
COPY poetry.lock pyproject.toml ./
RUN python -m pip install --no-cache-dir poetry==1.4.2 \
    && poetry export --without-hashes --without dev,test -f requirements.txt -o requirements.txt

# Defines a new base image to create the final image
FROM python:3.8.16-slim-bullseye

# Sets the working directory for the container
WORKDIR /app

# Copies the file requirements.txt from the previous stage of the build
# Installs dependencies from a file requirements.txt
COPY --from=builder requirements.txt ./
RUN python -m pip install --no-cache-dir -r requirements.txt

# Copies the installed dependencies from the previous build stage
COPY --from=builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages

# Copies files app.py and the img folder in the container
COPY app.py ./
COPY img ./img

# Launches the Flash application when the container is launched
CMD python3 -m flask run --host=0.0.0.0