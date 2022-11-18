
const express = require('express');
var admin = require("firebase-admin");
var cors = require('cors');
var serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const products = db.collection('pieces');
const orders = db.collection('orders');
const payments = db.collection('payments');


var app = express();
app.use(express.json());
app.use(cors());

app.post('/catalog', async function (req, res) {
	console.log(req.body);
	if (typeof req.body.brand !== 'undefined' && req.body.brand !== null){		
		try{
			var data = [];

			if(req.body.model == null && req.body.year == null) {
				products
				.where("brand", "==", req.body.brand)
				.get()
				.then((querySnapshot) => {
					querySnapshot.forEach((snapshotDocument) => {
						// console.log(snapshotDocument.id, " => ", snapshotDocument.data());
						data = data.concat(snapshotDocument.data());
					});

					if(Object.keys(data).length === 0) {
						res.json({data: null});
					} else {
						res.json({data: data});
					}
				})
				.catch((error) => {
				console.log("Error getting documents: ", error);
					res.sendStatus(500);
				});
			} else if(req.body.model !== null) {
				products
				.where("brand", "==", req.body.brand)
				.where("model", "==", req.body.model)
				.get()
				.then((querySnapshot) => {
					querySnapshot.forEach((snapshotDocument) => {
						// console.log(snapshotDocument.id, " => ", snapshotDocument.data());
						data = data.concat(snapshotDocument.data());
					});

					if(Object.keys(data).length === 0) {
						res.json({data: null});
					} else {
						res.json({data: data});
					}
				})
				.catch((error) => {
				console.log("Error getting documents: ", error);
					res.sendStatus(500);
				});
			} else if(req.body.year !== null) {
				products
				.where("brand", "==", req.body.brand)
				.where("year", "==", req.body.year)
				.get()
				.then((querySnapshot) => {
					querySnapshot.forEach((snapshotDocument) => {
						// console.log(snapshotDocument.id, " => ", snapshotDocument.data());
						data = data.concat(snapshotDocument.data());
					});

					if(Object.keys(data).length === 0) {
						res.json({data: null});
					} else {
						res.json({data: data});
					}
				})
				.catch((error) => {
				console.log("Error getting documents: ", error);
					res.sendStatus(500);
				});
			} else {
				products
				.where("brand", "==", req.body.brand)
				.where("model", "==", req.body.model)
				.where("year", "==", req.body.year)
				.get()
				.then((querySnapshot) => {
					querySnapshot.forEach((snapshotDocument) => {
						// console.log(snapshotDocument.id, " => ", snapshotDocument.data());
						data = data.concat(snapshotDocument.data());
					});

					if(Object.keys(data).length === 0) {
						res.json({data: null});
					} else {
						res.json({data: data});
					}
				})
				.catch((error) => {
				console.log("Error getting documents: ", error);
					res.sendStatus(500);
				});
			}
		}
		catch(error){
			console.log(error);
			res.sendStatus(400);
		}
	}
	else{
		res.sendStatus(500);
	}
})

app.post('/order', async function (req, res) {
	console.log(req.body);
	if (typeof req.body.items !== 'undefined' && req.body.items !== null 
		&& typeof req.body.clientName !== 'undefined' && req.body.clientName !== null ){		
		try{
			var articles = [];
			for(const orderItem of req.body.items) {
				await products
				.where("articleId", "==", orderItem["articleId"])
				.get()
				.then((querySnapshot) => {
					querySnapshot.forEach((snapshotDocument) => {
						const articleData = snapshotDocument.data();
						const article = {
							item: articleData["name"],
							itemId: articleData["articleId"],
							brand: articleData["brand"],
							model: articleData["model"],
							year: articleData["year"],
							price: articleData["price"],
							quantity: orderItem["quantity"],
							weight: articleData["weight"]
						};

						articles = articles.concat(article);
					});
				})
				.catch((error) => {
				console.log("Error getting documents: ", error);
					res.sendStatus(500);
				});
			}

			const newOrderId = "RSI-".concat(Date.now());


			const orderResult = await orders.add({
				orderId: newOrderId,
				issueDate: (new Date()).toLocaleDateString('en-GB'),
				clientLatitud: req.body.clientLatitud,
				clientLongitud: req.body.clientLongitud,
				clientName: req.body.clientName,
				status: false,
				delivery: null,
				deliveryCost: null,
				paymentStatus: null,
				deliveryDate: null,
				deliveryETA: null,
				deliveryServer: null,
				totalCost: null,
				estado: null,
				station: "RSI"
			});

			for(const article of articles) {
				await orders.doc(orderResult.id).collection("items").add(article);
			}
		
			res.json({orderId: newOrderId});
			console.log({orderId: newOrderId});
		}
		catch(error){
			console.log(error);
			res.sendStatus(400);
		}
	}
	else{
		res.sendStatus(500);
	}
})

app.post('/status', async function (req, res) {
	console.log(req.body);
	if (typeof req.body.orderId !== 'undefined' && req.body.orderId !== null){		
		try{
			orders
				.where("orderId", "==", req.body.orderId)
				.get()
				.then((querySnapshot) => {
					var data = {};
					querySnapshot.forEach((snapshotDocument) => {
						data = snapshotDocument.data();
					});

					if(Object.keys(data).length === 0) {
						res.json({
							status: null
						});
					} else {
						res.json({
							delivery: data["delivery"],
							status: data["estado"],
							deliveryCost: data["deliveryCost"],
						    paymentStatus: data["paymentStatus"],
						    deliveryDate: data["deliveryDate"],
						    deliveryETA: data["deliveryETA"],
						    deliveryServer: data["deliveryServer"],
						    totalCost: data["costoTotal"],
						});
					}
				})
				.catch((error) => {
				console.log("Error getting documents: ", error);
					res.sendStatus(500);
				});
		}
		catch(error){
			console.log(error);
			res.sendStatus(400);
		}
	}
	else{
		res.sendStatus(500);
	}
})

app.post('/delivery', async function (req, res) {
	console.log(req.body);
	console.log(req.body);
	res.sendStatus(200);

})

app.post('/payment', async function (req, res) {
	console.log(req.body);
	if (typeof req.body.orderId !== 'undefined' && req.body.orderId !== null){		
		try{
			orders
				.where("orderId", "==", req.body.orderId)
				.get()
				.then((querySnapshot) => {
					var data = {};
					querySnapshot.forEach((snapshotDocument) => {
						data = snapshotDocument.data();
					});

					if(Object.keys(data).length === 0) {
						res.json({
							status: null
						});
					} else {
						res.json({
							orderId: data["orderId"],
							paymentId: req.body.paymentId,
							status: "true",
						});
					}
				})
				.catch((error) => {
				console.log("Error getting documents: ", error);
					res.sendStatus(500);
				});

				await payments.add({
				orderId: req.body.orderId,
				paymentId: req.body.paymentId,
				status: true
			});

		}
		catch(error){
			console.log(error);
			res.sendStatus(400);
		}
	}
	else{
		res.sendStatus(500);
	}
})




var server = app.listen(process.env.PORT || 16000, function () {
   var host = server.address().host
   var port = server.address().port
   
   console.log("App listening at http://%s:%s", host, port)
})