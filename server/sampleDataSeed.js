const MongoClient = require('mongodb').MongoClient;
const url = 'mongodb+srv://username:password@yourcluster.mongodb.net/GymPlanner?retryWrites=true&w=majority';
const client = new MongoClient(url);

async function seed() {
  await client.connect();
  const db = client.db('GymPlanner');
  
  await db.collection('workouts').insertMany([
    { name: "Push Day", exercises: ["bench press", "shoulder press", "triceps"] },
    { name: "Pull Day", exercises: ["deadlift", "rows", "bicep curls"] },
    { name: "Leg Day", exercises: ["squat", "leg press", "lunges"] }
  ]);

  console.log('Test data inserted!');
  await client.close();
}

seed();