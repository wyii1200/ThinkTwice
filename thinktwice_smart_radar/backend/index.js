require("dotenv").config();
console.log("BUCKET:", process.env.FIREBASE_STORAGE_BUCKET);

const express = require("express");
const cors = require("cors");

const dealsRouter = require("./routes/deals");
const radarRouter = require("./routes/radar");

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ message: "ThinkTwice Smart Radar Service is running" });
});

app.use("/deals", dealsRouter);
app.use("/radar", radarRouter);

app.listen(PORT, () => {
  console.log(`Smart Radar service running on port ${PORT}`);
});