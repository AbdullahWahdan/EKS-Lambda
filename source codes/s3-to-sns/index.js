const axios = require("axios");

exports.handler = async (event) => {
  console.log("S3 Event:", JSON.stringify(event, null, 2));

  const record = event.Records[0];
  const bucket = record.s3.bucket.name;
  const key = decodeURIComponent(record.s3.object.key.replace(/\+/g, " "));

  const imageUrl = `https://${bucket}.s3.amazonaws.com/${key}`;
  console.log("Image URL:", imageUrl);

  try {
    const response = await axios.post("http://a3b010f7493c34f12b3475f1a26e77f0-391251976.us-east-1.elb.amazonaws.com", { imageUrl });
    console.log("Response from EKS service:", response.data);
  } catch (error) {
    console.error("Error sending request to EKS service:", error);
  }

  return { statusCode: 200 };
};
