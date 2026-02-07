# Kids Story Generator

This project generates children stories using Hugging Face API hosted in an Azure Function.

## Features

- Input: topic, age group, theme
- Generates fun and age-appropriate stories
- React frontend embedded in a single HTML file
- Backend Azure Function calls Hugging Face securely

## Deployment

1. Push repo to GitHub.
2. Create Azure Function App (Node.js 18) in the Azure Portal.
3. Set `HUGGINGFACE_API_KEY` in Configuration → Application Settings.
4. Connect GitHub repo in Deployment Center for automatic deployment.
5. Update frontend HTML to call your Azure Function URL.

