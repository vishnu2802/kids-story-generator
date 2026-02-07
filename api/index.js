const { app } = require('@azure/functions');

app.http('generateStory', {
    methods: ['POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        context.log('Story generation request received');

        try {
            const body = await request.json();
            const { topic, ageGroup, theme } = body;

            if (!topic || !ageGroup || !theme) {
                return {
                    status: 400,
                    jsonBody: {
                        error: 'topic, ageGroup, and theme are required'
                    }
                };
            }

            const prompt = `
Write a ${theme} story for children aged ${ageGroup} about ${topic}.
Make it engaging, fun, and age-appropriate.
Include a clear beginning, middle, and end.
Keep it between 200 and 300 words.
            `.trim();

            const response = await fetch(
                'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2',
                {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${process.env.HUGGINGFACE_API_KEY}`
                    },
                    body: JSON.stringify({
                        inputs: prompt,
                        parameters: {
                            max_new_tokens: 350,
                            temperature: 0.8,
                            return_full_text: false
                        }
                    })
                }
            );

            if (!response.ok) {
                const err = await response.text();
                throw new Error(err);
            }

            const data = await response.json();

            return {
                status: 200,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                jsonBody: {
                    story: data[0].generated_text
                }
            };

        } catch (error) {
            context.log('Error:', error);
            return {
                status: 500,
                jsonBody: { error: 'Failed to generate story' }
            };
        }
    }
});
