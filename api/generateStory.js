export default async function (req, context) {
  try {
    const { topic, ageGroup, theme } = await req.json();

    if (!topic || !ageGroup || !theme) {
      return new Response(
        JSON.stringify({ error: 'topic, ageGroup, theme are required' }),
        { status: 400 }
      );
    }

    const prompt = `
Write a ${theme} story for children aged ${ageGroup} about ${topic}.
Make it fun, engaging, and age-appropriate.
Include a clear beginning, middle, and end.
Keep it between 200 and 300 words.
    `.trim();

    const hfResponse = await fetch(
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
            top_p: 0.9,
            return_full_text: false
          }
        })
      }
    );

    if (!hfResponse.ok) {
      throw new Error(await hfResponse.text());
    }

    const data = await hfResponse.json();

    return new Response(
      JSON.stringify({ story: data[0].generated_text }),
      { headers: { 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    context.log(err);
    return new Response(
      JSON.stringify({ error: 'Failed to generate story' }),
      { status: 500 }
    );
  }
}
