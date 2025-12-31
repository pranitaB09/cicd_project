const healthCheck = (req, res) => {
  res.status(200).json({
    success: true,
    message: "Backend is healthy",
  });
};

export default healthCheck;
