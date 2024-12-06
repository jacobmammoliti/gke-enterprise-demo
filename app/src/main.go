package main

import (
	"github.com/gin-gonic/gin"
	"net/http"
	"os"
)

// album represents data about a record album.
type album struct {
	ID     string `json:"id"`
	Title  string `json:"title"`
	Artist string `json:"artist"`
	Year   string `json:"year"`
}

// info represents data about the service.
type info struct {
	SourceIP    string      `json:"source_ip"`
	Hostname    string      `json:"hostname"`
	UserID      int         `json:"uid"`
	ProcessID   int         `json:"pid"`
	GroupID     int         `json:"gid"`
	Headers     http.Header `json:"headers"`
	Environment []string    `json:"environment"`
}

// albums slice to seed record album data.
var albums = []album{
	{ID: "1", Title: "Random Album Title", Artist: "deadmau5", Year: "2008"},
	{ID: "2", Title: "For Lack of a Better Name", Artist: "deadmau5", Year: "2009"},
	{ID: "3", Title: "4x4=12", Artist: "deadmau5", Year: "2010"},
}

func main() {
	router := gin.Default()
	router.GET("/albums", getAlbums)
	router.GET("/albums/:id", getAlbumByID)
	router.POST("/albums", postAlbums)
	router.GET("/health", getHealth)
	router.GET("/info", getInfo)

	router.Run("0.0.0.0:8080")
}

// getHealth responds with the health of the service.
func getHealth(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, gin.H{"status": "ok"})
}

// getInfo responds with verbose details of the service.
func getInfo(c *gin.Context) {
	name, err := os.Hostname()

	if err != nil {
		name = "unknown"
	}

	environment := os.Environ()

	h := info{
		SourceIP:    c.ClientIP(),
		Hostname:    name,
		UserID:      os.Getuid(),
		ProcessID:   os.Getpid(),
		GroupID:     os.Getgid(),
		Headers:     c.Request.Header,
		Environment: environment,
	}

	c.IndentedJSON(http.StatusOK, h)
}

// getAlbums responds with the list of all albums as JSON.
func getAlbums(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, albums)
}

// postAlbums adds an album from JSON received in the request body.
func postAlbums(c *gin.Context) {
	var newAlbum album

	// Call BindJSON to bind the received JSON to
	// newAlbum.
	if err := c.BindJSON(&newAlbum); err != nil {
		return
	}

	// Add the new album to the slice.
	albums = append(albums, newAlbum)
	c.IndentedJSON(http.StatusCreated, newAlbum)
}

// getAlbumByID locates the album whose ID value matches the id
// parameter sent by the client, then returns that album as a response.
func getAlbumByID(c *gin.Context) {
	id := c.Param("id")

	// Loop through the list of albums, looking for
	// an album whose ID value matches the parameter.
	for _, a := range albums {
		if a.ID == id {
			c.IndentedJSON(http.StatusOK, a)
			return
		}
	}
	c.IndentedJSON(http.StatusNotFound, gin.H{"message": "album not found"})
}
