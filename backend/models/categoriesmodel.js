const mongoose = require("mongoose");

const categorySchema = new mongoose.Schema({
  name: { type: String, required: true },
  iconUrl: { type: String }
});

module.exports = mongoose.model("Category", categorySchema);
