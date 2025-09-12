import dotenv from "dotenv";
import mongoose from "mongoose"

dotenv.config({ path: "./.env" });

const DB_URL = process.env.DB_URL;

//Database Connection
mongoose
.connect(DB_URL)
.then(() =>{
    console.log(`DB Connected at ${DB_URL}`)})
.catch(() => {
    console.log(`DB Connection error!`);});

export default mongoose;