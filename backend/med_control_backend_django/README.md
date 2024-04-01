## Django Server for med_Control

This Django project is a REST server that provides and saves data for med control

## Installation

Clone the repository to your local machine:

bash

    git clone https://github.com/your_username/your_project.git

Install the required packages using pip:

bash

    pip install -r requirements.txt

Create a new Elasticsearch index:

bash

    python manage.py search_index --rebuild

Start the server:

bash

    python manage.py runserver

