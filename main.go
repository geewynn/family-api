package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"github.com/segmentio/kafka-go"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type DB struct {
	collection *mongo.Collection
}

type Friends struct {
	ID         interface{} `json:"id" bson:"_id,omitempty"`
	Name       string      `json:"name" bson:"name"`
	Age        int         `json:"age" bson:"age"`
	Gender     string      `json:"gender" bson:"gender"`
	Occupation string      `json:"occupation" bson:"occupation"`
	Numbers    []string    `json:"numbers" bson:"numbers"`
	Interests  []string    `json:"interests" bson:"interests"`
	MetHow     []string    `json:"methow" bson:"methow"`
}

type Parents struct {
	ID         interface{} `json:"id" bson:"_id,omitempty"`
	Name       string      `json:"name" bson:"name"`
	Age        int         `json:"age" bson:"age"`
	Gender     string      `json:"gender" bson:"gender"`
	Occupation string      `json:"occupation" bson:"occupation"`
	Numbers    []string    `json:"numbers" bson:"numbers"`
	Children   Children    `json:"children" bson:"children"`
	Friends    Friends     `json:"friends" bson:"friends"`
}

type Children struct {
	ID         interface{} `json:"id" bson:"_id,omitempty"`
	Name       string      `json:"name" bson:"name"`
	Age        int         `json:"age" bson:"age"`
	Gender     string      `json:"gender" bson:"gender"`
	Occupation string      `json:"occupation" bson:"occupation"`
	Interests  []string    `json:"interests" bson:"interests"`
	Friends    Friends     `json:"friends" bson:"friends"`
}

func (db *DB) GetParent(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	var parents Parents
	objectID, _ := primitive.ObjectIDFromHex(vars["id"])
	filter := bson.M{"_id": objectID}
	err := db.collection.FindOne(context.TODO(), filter).Decode(&parents)

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
	} else {
		w.Header().Set("Content-Type", "application/json")
		response, _ := json.Marshal(parents)
		w.WriteHeader(http.StatusOK)
		w.Write(response)
	}

}

func (db *DB) GetAllParent(w http.ResponseWriter, r *http.Request) {
	data, err := db.collection.Find(context.TODO(), bson.M{})

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
		return
	}
	defer data.Close(context.TODO())
	for data.Next(context.TODO()) {
		var parent bson.M
		data.Decode(&parent)
		// parents = append(parents, parent)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte(err.Error()))
			return
		} else {
			w.Header().Set("Content-Type", "application/json")
			response, _ := json.Marshal(parent)
			//w.WriteHeader(http.StatusOK)
			w.Write(response)
		}

	}

}

func (db *DB) PostParent(w http.ResponseWriter, r *http.Request) {
	var parents Parents
	postBody, _ := ioutil.ReadAll(r.Body)
	json.Unmarshal(postBody, &parents)
	result, _ := db.collection.InsertOne(context.TODO(), parents)

	topic := "my-topics" //"foos"
	partition := 0
	conn, err := kafka.DialLeader(context.Background(), "tcp", "34.72.8.193:9094", topic, partition)

	if err != nil {
		fmt.Println("failed to dial leader:", err)
	}

	_, err = conn.WriteMessages(
		kafka.Message{Value: []byte(postBody)},
	)
	if err != nil {
		fmt.Println("failed to write messages:", err)
	}
	if err := conn.Close(); err != nil {
		fmt.Println("failed to close writer:", err)
	}

	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
	} else {
		w.Header().Set("Content-Type", "application/json")
		response, _ := json.Marshal(result)
		w.WriteHeader(http.StatusOK)
		w.Write(response)
	}

}

func main() {
	uri := fmt.Sprintf("mongodb://%s:%s@%s:%s",
		os.Getenv("DBUSER"),
		os.Getenv("DBPASSWORD"),
		os.Getenv("DBHOST"),
		os.Getenv("DBPORT"),
	)
	fmt.Println(uri)
	dbname := os.Getenv("DBNAME")
	dbcollection := os.Getenv("DBCOLLECTION")

	clientOptions := options.Client().ApplyURI(uri)

	// clientOptions := options.Client().ApplyURI("mongodb://dbuser:dbtestpassword@34.132.241.132:27017")
	client, err := mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		panic(err)

	}
	defer client.Disconnect(context.TODO())

	collection := client.Database(dbname).Collection(dbcollection)
	db := &DB{collection: collection}

	r := mux.NewRouter()
	r.HandleFunc("/v1/parent/all", db.GetAllParent).Methods("GET")
	r.HandleFunc("/v1/parent/{id:[a-zA-Z0-9]*}", db.GetParent).Methods("GET")
	r.HandleFunc("/v1/parent", db.PostParent).Methods("POST")

	srv := &http.Server{
		Handler:      r,
		Addr:         ":8000",
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}
	log.Fatal(srv.ListenAndServe())

}
