package eventsdb

import (
	"context"
	"fmt"
	"log"

	"cloud.google.com/go/datastore"
	"github.com/google/uuid"
)

type Event struct {
	ID       string
	Title    string `datastore:"title"`
	Location string `datastore:"location"`
	When     string `datastore:"when"`
}

var Events []Event

func createClient(ctx context.Context) *datastore.Client {
	// Sets your Google Cloud Platform project ID.
	projectID := "roi-takeoff-user10"
	// !! ^^^^^^^^^^^^ !!!

	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	// Close client when done with
	// defer client.Close()
	return client
}

func GetEvents() []Event {
	ctx := context.Background()
	client := createClient(ctx)
	defer client.Close()

	var docos []Event

	query := datastore.NewQuery("Event")
	keys, err := client.GetAll(ctx, query, &docos)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}
	for i, key := range keys {
		docos[i].Title = key.Name
	}
	return docos
}

func AddEvent(event Event) {
	ctx := context.Background()
	client := createClient(ctx)
	defer client.Close()
	newID := uuid.New().String()
	event.ID = newID

	k := datastore.NameKey("Event", "Event"+event.ID, nil)
	_, err := client.Put(ctx, k, &event)
	if err != nil {
		fmt.Println(err)
	}
	log.Println("New event:", event)
}

func DeleteEvent(id string) {
	ctx := context.Background()
	client := createClient(ctx)
	defer client.Close()

	k := datastore.NameKey("Event", id, nil)
	if err := client.Delete(ctx, k); err != nil {
		// Handle any errors in an appropriate way, such as returning them.
		log.Printf("An error has occurred: %s", err)
	}
	log.Println("Deleted event with id: ", id)
}
