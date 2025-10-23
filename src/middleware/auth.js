import jwt from "jsonwebtoken";

const authMiddleware = (req, res, next) => {
  // Get the token from the Authorization header
  const token = req.header('Authorization')?.replace('Bearer ', '');

  // Check if no token is provided
  if (!token) {
    return res.status(401).json({ message: 'No token, authorization denied.' });
  }

  // Verify the token
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    // Add the user's ID from the token payload to the request object
    req.user = decoded; 
    next(); // Pass control to the next handler (the actual route logic)
  } catch (err) {
    res.status(401).json({ message: 'Token is not valid.' });
  }
};

export default authMiddleware;
