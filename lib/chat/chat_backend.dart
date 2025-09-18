// import React, { useEffect, useState, useRef } from "react";
// import io from "socket.io-client";
// import axios from "axios";
//
// const socket = io("https://api.thebharatworks.com/");
//
// const App = () => {
// const userId = "68abec670fa4a01b9b742ddf"; // TODO: Get from auth context
// const [conversations, setConversations] = useState([]);
// const [currentChat, setCurrentChat] = useState(null);
// const [messages, setMessages] = useState([]);
// const [message, setMessage] = useState("");
// const [images, setImages] = useState([]); // State for multiple images
// const [onlineUsers, setOnlineUsers] = useState([]);
// const [receiverId, setReceiverId] = useState("");
// const scrollRef = useRef();
//
// // Fetch conversations
// useEffect(() => {
// const fetchConversations = async () => {
// try {
// const res = await axios.get(`https://api.thebharatworks.com/api/chat/conversations/${userId}`, {
// headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
// });
// setConversations(res.data.conversations || []);
// } catch (err) {
// console.error("Failed to fetch conversations:", err);
// }
// };
// fetchConversations();
// }, [userId]);
//
// // Join Socket
// useEffect(() => {
// socket.emit("addUser", userId);
// socket.on("getUsers", (users) => {
// setOnlineUsers(users);
// });
// return () => socket.off("getUsers");
// }, [userId]);
//
// // Fetch messages when chat is selected
// useEffect(() => {
// const fetchMessages = async () => {
// if (currentChat) {
// try {
// const res = await axios.get(`https://api.thebharatworks.com/api/chat/messages/${currentChat._id}`, {
// headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
// });
// setMessages(res.data.messages || []);
// } catch (err) {
// console.error("Failed to fetch messages:", err);
// }
// }
// };
// fetchMessages();
// }, [currentChat]);
//
// // Receive message from socket
// useEffect(() => {
// socket.on("getMessage", (data) => {
// if (currentChat && data.conversationId === currentChat._id) {
// setMessages((prev) => [...prev, data]);
// }
// });
// return () => socket.off("getMessage");
// }, [currentChat]);
//
// // Start a new conversation
// const startConversation = async () => {
// if (!receiverId) {
// alert("Please enter a receiver ID");
// return;
// }
// try {
// const res = await axios.post(
// "https://api.thebharatworks.com/api/chat/conversations",
// { senderId: userId, receiverId },
// { headers: { Authorization: `Bearer ${localStorage.getItem("token")}` } }
// );
// const newConversation = res.data.conversation;
// setConversations((prev) => [...prev, newConversation]);
// setCurrentChat(newConversation);
// setReceiverId("");
// } catch (err) {
// console.error("Failed to start conversation:", err);
// alert("Failed to start conversation");
// }
// };
//
// // Handle image selection
// const handleImageChange = (e) => {
// const files = Array.from(e.target.files);
// if (files.length > 5) {
// alert("Maximum 5 images allowed");
// return;
// }
// setImages(files);
// };
//
// // Send message (text or images)
// const sendMessage = async () => {
// if (!message.trim() && images.length === 0) return;
// const receiverId = "68ac1a6900315e754a038c80";
// if (!receiverId) {
// alert("Receiver ID not found in conversation");
// return;
// }
//
// try {
// let newMsg;
// if (images.length > 0) {
// // Upload images
// const formData = new FormData();
// images.forEach((image) => formData.append("images", image)); // Match backend field name
// formData.append("senderId", userId);
// formData.append("receiverId", receiverId);
// formData.append("conversationId", currentChat._id);
// formData.append("messageType", "image");
// if (message.trim()) formData.append("message", message);
//
// const res = await axios.post("https://api.thebharatworks.com/api/chat/messages", formData, {
// headers: {
// Authorization: `Bearer ${localStorage.getItem("token")}`,
// "Content-Type": "multipart/form-data",
// },
// });
// newMsg = res.data.newMessage;
// } else {
// // Send text message
// newMsg = {
// senderId: userId,
// receiverId,
// conversationId: currentChat._id,
// message,
// messageType: "text",
// };
// const res = await axios.post("https://api.thebharatworks.com/api/chat/messages", newMsg, {
// headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
// });
// newMsg = res.data.newMessage;
// }
//
// socket.emit("sendMessage", newMsg);
// setMessages((prev) => [...prev, newMsg]);
// setMessage("");
// setImages([]); // Clear images after sending
// } catch (err) {
// console.error("Failed to send message:", err);
// alert("Failed to send message");
// }
// };
//
// // Auto-scroll to latest message
// useEffect(() => {
// scrollRef.current?.scrollIntoView({ behavior: "smooth" });
// }, [messages]);
//
// return (
// <div style={{ display: "flex", height: "100vh" }}>
// {/* Sidebar */}
// <div style={{ width: "30%", borderRight: "1px solid #ccc" }}>
// <h3 style={{ padding: "10px" }}>Chats</h3>
// <div style={{ padding: "10px" }}>
// <input
// type="text"
// placeholder="Enter receiver ID"
// value={receiverId}
// onChange={(e) => setReceiverId(e.target.value)}
// style={{ width: "70%", padding: "5px" }}
// />
// <button onClick={startConversation} style={{ padding: "5px" }}>
// Start Chat
// </button>
// </div>
// {Array.isArray(conversations) &&
// conversations.map((conv) => {
// const otherUser = conv.members.find((m) => m._id !== userId);
// return (
// <div
// key={conv._id}
// onClick={() => setCurrentChat(conv)}
// style={{
// padding: "10px",
// cursor: "pointer",
// background: conv._id === currentChat?._id ? "#f0f0f0" : "white",
// }}
// >
// <strong>{otherUser?.name || "User"}</strong>
// <br />
// <small>{conv.lastMessage}</small>
// </div>
// );
// })}
// </div>
//
// {/* Chat Box */}
// <div style={{ width: "70%", position: "relative", display: "flex", flexDirection: "column" }}>
// <div style={{ flex: 1, padding: "10px", overflowY: "auto" }}>
// {messages.map((msg, index) => (
// <div
// key={msg._id}
// ref={index === messages.length - 1 ? scrollRef : null}
// style={{
// textAlign: msg.senderId === userId ? "right" : "left",
// marginBottom: "8px",
// }}
// >
// <div
// style={{
// display: "inline-block",
// backgroundColor: msg.senderId === userId ? "#dcf8c6" : "#fff",
// padding: "10px",
// borderRadius: "10px",
// maxWidth: "60%",
// }}
// >
// {msg.messageType === "image" && msg.image?.length > 0 ? (
// <div>
// {msg.image.map((imgUrl, idx) => (
// <img
// key={idx}
// src={`https://api.thebharatworks.com/${imgUrl}`} // Prepend server URL
// alt="Sent image"
// style={{ maxWidth: "100%", maxHeight: "200px", borderRadius: "10px", marginBottom: "5px" }}
// />
// ))}
// {msg.message && <div>{msg.message}</div>} {/* Display text if included */}
// </div>
// ) : (
// msg.message
// )}
// </div>
// </div>
// ))}
// </div>
//
// {/* Input */}
// {currentChat && (
// <div style={{ padding: "10px", display: "flex", gap: "10px", alignItems: "center" }}>
// <input
// type="text"
// placeholder="Type a message..."
// value={message}
// onChange={(e) => setMessage(e.target.value)}
// style={{ flex: 1, padding: "10px" }}
// />
// <input
// type="file"
// accept="image/*"
// multiple // Allow multiple file selection
// onChange={handleImageChange}
// style={{ padding: "5px" }}
// />
// <button onClick={sendMessage}>Send</button>
// </div>
// )}
// </div>
// </div>
// );
// };
//
// export default App;
//
// const express = require("express");
// const connectDB = require("./config/db.js");
// const cookieParser = require("cookie-parser");
// const bodyParser = require("body-parser");
// const cors = require("cors");
// const path = require("path");
// require("dotenv").config();
// const { notFound, errorHandler } = require("./middleware/errorMiddleware.js");
// const http = require("http");
// const { Server } = require("socket.io");
// // ****************** Routes ***********************
// const { userRoutes } = require("./routes/userRoutes.js");
// const { adminRoutes } = require("./routes/adminRoutes.js");
// const { companyDetails } = require("./routes/companydetailsRoutes.js");
// const { faqRoutes } = require("./routes/faqRoutes.js");
// const { workCategoryRoutes } = require("./routes/workCatergoryRoutes.js");
// const { workSubCategoryRoutes } = require("./routes/workSubCategoryRoutes.js");
// const { platformFeeRoutes } = require("./routes/platformFeeRoutes.js");
// const { directHireRoutes } = require("./routes/directHireRoutes.js");
// const { disputeRoutes } = require("./routes/disputeRoutes.js");
// const { workerRoutes } = require("./routes/workerRoutes");
// const { biddingHireRoutes } = require("./routes/biddingHireRoutes.js");
// const { emergencyHireRoutes } = require("./routes/emergencyHireRoutes.js");
// const negotiationRoutes = require("./routes/negotiationRoutes");
// const { chatRoutes } = require("./routes/chatRoutes.js");
// const { promotionRoutes } = require("./routes/promotionRoutes.js");
// const { subscriptionRoutes } = require("./routes/subscriptionRoutes.js");
// const { bannerRoutes } = require("./routes/bannerRoutes.js");
// // end
// require("./cron/subscriptionReset");
//
// connectDB();
// const app = express();
// app.use(cookieParser());
// const __dirname1 = path.resolve();
// app.use(express.static(path.join(__dirname1, "")));
// app.use("/public", express.static("public"));
// app.use("/uploads", express.static("uploads"));
// app.use(express.json());
//
// const corsOptions = {
// origin: (origin, callback) => {
// callback(null, true);
// },
// };
//
// app.use(cors(corsOptions));
//
// //***********************  Define Routes************************* */
// app.use("/api/user", userRoutes);
// app.use("/api/admin", adminRoutes);
// app.use("/api", workCategoryRoutes);
// app.use("/api", workSubCategoryRoutes);
// app.use("/api/CompanyDetails", companyDetails);
// app.use("/api", faqRoutes);
// app.use("/api", platformFeeRoutes);
// app.use("/api/direct-order", directHireRoutes);
// app.use("/api/bidding-order", biddingHireRoutes);
// app.use("/api/emergency-order", emergencyHireRoutes);
// app.use("/api/dispute", disputeRoutes);
// app.use("/api/worker", workerRoutes);
// app.use("/api/negotiations", negotiationRoutes);
// app.use("/api/chat", chatRoutes);
// app.use("/api/promotion", promotionRoutes);
// app.use("/api/banner", bannerRoutes);
// app.use("/api/subscription", subscriptionRoutes);
//
// // --------------------------deploymentssssss------------------------------
//
// if (process.env.NODE_ENV == "production") {
// app.use(express.static(path.join(__dirname1, "/view")));
//
// app.get("*", (req, res) =>
// res.sendFile(path.resolve(__dirname1, "view", "index.html"))
// );
// } else {
// app.get("/", (req, res) => {
// res.send("API is running..");
// });
// }
//
// // --------------------------deployment------------------------------
//
// // Error handling middleware
// app.use((err, req, res, next) => {
// const statusCode = err.statusCode || 500;
// res.status(statusCode).json({
// message: err.message || "Internal Server Error",
// status: false,
// });
// });
//
// // Error Handling middlewares
// app.use(notFound);
// app.use(errorHandler);
// app.use(bodyParser.json({ limit: "100mb" }));
// app.use(bodyParser.urlencoded({ limit: "100mb", extended: true }));
//
// // const PORT = process.env.PORT;
// // const BASE_URL = process.env.BASE_URL;
//
// // const server = app.listen(PORT, () => {
// //   console.log(`Server running on PORT ${PORT}...`);
// //   console.log(`Base URL: ${BASE_URL}`);
// // });
// // ... your existing middleware and routes
//
// const PORT = process.env.PORT;
// const BASE_URL = process.env.BASE_URL;
//
// const server = http.createServer(app);
// const io = new Server(server, {
// cors: {
// origin: "*", // Specify frontend URL
// methods: ["GET", "POST"],
// },
// });
//
// let onlineUsers = {};
//
// io.on("connection", (socket) => {
// // console.log("Socket connected:", socket.id);
//
// // Register user
// socket.on("addUser", (userId) => {
// if (userId) {
// onlineUsers[userId] = socket.id;
// io.emit("getUsers", Object.keys(onlineUsers));
// }
// });
//
// // Handle sending messages
// socket.on("sendMessage", (msgData) => {
// const {
// receiverId,
// conversationId,
// senderId,
// message,
// messageType,
// image,
// } = msgData;
// if (!receiverId || !conversationId || !senderId) return;
//
// const receiverSocketId = onlineUsers[receiverId];
// const formattedMsg = {
// conversationId,
// senderId,
// receiverId,
// message: message || "",
// messageType: messageType || "text",
// image: image || "",
// createdAt: new Date(),
// };
//
// if (receiverSocketId) {
// // console.log(receiverSocketId, formattedMsg);
// io.to(receiverSocketId).emit("getMessage", formattedMsg);
// }
// if (onlineUsers[senderId]) {
// io.to(onlineUsers[senderId]).emit("messageSent", formattedMsg);
// }
// });
//
// // Disconnect
// socket.on("disconnect", () => {
// const disconnectedUser = Object.keys(onlineUsers).find(
// (key) => onlineUsers[key] === socket.id
// );
// if (disconnectedUser) {
// delete onlineUsers[disconnectedUser];
// io.emit("getUsers", Object.keys(onlineUsers));
// }
// // console.log("Socket disconnected:", socket.id);
// });
// });
//
// server.listen(PORT, () => {
// console.log(`Server running on PORT ${PORT}`);
// console.log(`Base url ${BASE_URL}`);
// });