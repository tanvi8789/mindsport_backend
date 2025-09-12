import app from "./app.js";
import dotenv from "dotenv";
import "./db/mongo.js";

dotenv.config({ path: "./.env" });  // ensures file is always found

console.log("This app Works!");

const PORT = process.env.PORT || 3000;


app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});