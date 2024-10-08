class APIFeatures {
  constructor(query, queryString) {
    this.query = query;
    this.queryString = queryString;
  }

  filter() {
    const queryObj = { ...this.queryString };
    const excludedFields = ['page', 'sort', 'limit', 'fields'];
    excludedFields.forEach((el) => delete queryObj[el]);
  
    // Advanced filtering: apply regex for the `title` field if it exists in the query
    if (queryObj.title) {
      queryObj.title = { $regex: queryObj.title, $options: "i" }; // Case-insensitive regex search
    }
  
    // Handle gte, gt, lte, lt operators for other fields
    let queryStr = JSON.stringify(queryObj);
    queryStr = queryStr.replace(/\b(gte|gt|lte|lt)\b/g, (match) => `$${match}`);
  
    console.log("Final query object:", queryObj);


    // Apply filtering
    this.query = this.query.find(JSON.parse(queryStr));
  
    
    return this;
  }
  
  sort() {
    if (this.queryString.sort) {
      const sortBy = this.queryString.sort.split(",").join(" ");
      this.query = this.query.sort(sortBy);
    } else {
      this.query = this.query.sort("-createdAt");
    }
    return this;
  }

  limitFields() {
    //4)field limiting

    if (this.queryString.fields) {
      const fields = this.queryString.fields.split(",").join(" ");
      this.query = this.query.select(fields);
    } else {
      this.query = this.query.select("-__v");
    }
    return this;
  }

  paginate() {
    //5) pagination
    const page = this.queryString.page * 1 || 1;
    const limit = this.queryString.limit * 1 || 100;
    const skip = (page - 1) * limit;

    // page=2&limit=10, 1-10 page1 , 11-20 page 2 , 21-30 page 3 . .. .. . .
    this.query = this.query.skip(skip).limit(limit);

    return this;
  }
}
module.exports = APIFeatures;
