const OpenAI = require("openai");
const Replicate = require("replicate");
const functions = require("firebase-functions");

// Place your API Keys Here
const openai = new OpenAI({
  apiKey: "",
});

const replicate = new Replicate({
  auth: "",
});

// Firebase cloud functions for Image Generation as well as trash

// Test function
exports.rubbishTest = functions.https.onRequest(async (req, res) => {
  functions.logger.info("Hello logs!", { structuredData: true });
  res.status(200).json({ message: "successfull test" });
});

// Bin Sorter - identifies trash in the picture and returns the correct bin to place the item
exports.binSorter = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const { imageUrl, location } = req.body;

  if (!imageUrl) {
    return res.status(400).send("No Image URL Provided");
  }

  if (!location) {
    return res.status(400).send("A location is required");
  }

  const improvedPrompt = `
    This cloud function analyzes an image of an item and its location to determine the appropriate disposal method.
    The location is ${location}.
    The function performs the following steps:
    1. Identifies the type of item from the image.
    2. Determines the correct disposal bin (trash, recycling, compost, or special) based on the item type and the specific waste management guidelines of the provided location.

    The function outputs the results in the following JSON format:
    "{ Result: In ${location}, the item should be categorized as [disposal type] and disposed of in the [bin type] bin.
       BinType: - pick one option: trash, recycling, compost, special-,
      }
    "

    Example output:
    {
      Result: In Los Angeles, the item should be categorized as trash and disposed of in the trash bin.
      BinType: trash
    }
  `;

  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4-vision-preview",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: improvedPrompt,
            },
            {
              type: "image_url",
              image_url: {
                url: imageUrl,
              },
            },
          ],
        },
      ],
      max_tokens: 300,
    });

    return res.json(response.choices[0].message.content);
  } catch (error) {
    console.error("Error calling OpenAI Vision API:", error);
    res.status(500).send("Error processing image" + error.message);
  }
});

const imageDescriptionPrompt = `Please describe the image in as much detail as possible. It will be for an artist to practice their skills. Do not provide anything else other than the description.`;
const theme = "cartoon";

// Image Creator - takes in an image returns an image based on the theme
module.exports.imageCreator = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  // Takes in imageData as base64 string
  const { imageUrl } = req.body;
  if (!imageUrl) {
    return res.status(400).send("No image url provided. ");
  }

  try {
    const response = await openai.chat.completions.create({
      model: "gpt-4-vision-preview",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "text",
              text: imageDescriptionPrompt,
            },
            {
              type: "image_url",
              image_url: {
                url: `${imageUrl}`,
              },
            },
          ],
        },
      ],
      max_tokens: 300,
    });

    let result = response.choices[0].message.content;

    let temp = result.split("\n\n");

    let description;
    if (temp.length > 1) {
      // If there are multiple paragraphs, slice all but the last one
      description = temp.slice(0, temp.length - 1).join("\n\n");
    } else {
      // If there's only one paragraph, return it as is or handle accordingly
      description = temp[0];
    }

    const dalle3Prompt = `
              Can you create an image from this description?

              ${description}

              Please make it ${theme} themed.
              `;

    const image = await openai.images.generate({
      model: "dall-e-3",
      prompt: dalle3Prompt,
    });

    console.log("checking image object", image);

    console.log("image data", image.data);

    return res.json({ image: image.data });
  } catch (error) {
    console.error("Error calling OpenAI Vision API:", error);
    res.status(500).send("Error processing image");
  }
});

const theme2 = "superhero";

// Image Creator - takes in an image returns an image based on the theme. In this case, the theme is superhero
module.exports.superHeroCreator = functions.https.onRequest(
  async (req, res) => {
    if (req.method !== "POST") {
      return res.status(405).send("Method Not Allowed");
    }

    // Takes in imageData as base64 string
    const { imageUrl } = req.body;
    if (!imageUrl) {
      return res.status(400).send("No image url provided. ");
    }

    try {
      const response = await openai.chat.completions.create({
        model: "gpt-4-vision-preview",
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: imageDescriptionPrompt,
              },
              {
                type: "image_url",
                image_url: {
                  url: `${imageUrl}`,
                },
              },
            ],
          },
        ],
        max_tokens: 300,
      });

      let result = response.choices[0].message.content;

      let temp = result.split("\n\n");

      let description;
      if (temp.length > 1) {
        // If there are multiple paragraphs, slice all but the last one
        description = temp.slice(0, temp.length - 1).join("\n\n");
      } else {
        // If there's only one paragraph, return it as is or handle accordingly
        description = temp[0];
      }

      const dalle3Prompt = `
              Can you create an image from this description?

              ${description}

              Please make it ${theme2} themed. I want the image to be animated, similar to a pixar or marvel, not realistic.
              `;

      const image = await openai.images.generate({
        model: "dall-e-3",
        prompt: dalle3Prompt,
      });

      console.log("checking image object", image);

      console.log("image data", image.data);

      return res.json({ image: image.data });
    } catch (error) {
      console.error("Error calling OpenAI Vision API:", error);
      res.status(500).send("Error processing image");
    }
  }
);

// Alternative model to OpenAI, utilizing Replicate API and image models
exports.replicateModel = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  // Takes in imageData as base64 string
  const { imageUrl } = req.body;
  if (!imageUrl) {
    return res.status(400).send("No image url provided. ");
  }

  try {
    const output = await replicate.run(
      "catacolabs/cartoonify:f109015d60170dfb20460f17da8cb863155823c85ece1115e1e9e4ec7ef51d3b",
      {
        input: {
          image: imageUrl,
        },
      }
    );

    return res.json({ image: output });
  } catch (e) {
    console.error("Error calling Replicate API:", error);
    res.status(500).send("Error processing image");
  }
});
