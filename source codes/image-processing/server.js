import express from "express";
import bodyParser from "body-parser";

const app = express();
app.use(bodyParser.json());

app.post("/", async (req, res) => {
  const { imageUrl } = req.body;
  console.log("Received image URL:", imageUrl);

  

  res.json({ message: "Image processed successfully", url: imageUrl });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});