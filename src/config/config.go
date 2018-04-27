package config

import (
	"io/ioutil"
	"log"
	"os"

	yaml "gopkg.in/yaml.v2"
)

// GlobalConfig is the global config
type GlobalConfig struct {
	Server ServerConfig `yaml:"server"`
}

// ServerConfig is the server config
type ServerConfig struct {
	Version string
}

// global configs
var (
	Global GlobalConfig
	Server ServerConfig
)

// Load config from file
func Load(file string) (GlobalConfig, error) {
	data, err := ioutil.ReadFile(file)
	if err != nil {
		log.Printf("%v", err)
		return Global, err
	}

	err = yaml.Unmarshal(data, &Global)
	if err != nil {
		log.Printf("%v", err)
		return Global, err
	}

	Server = Global.Server

	return Global, nil
}

// loads configs
func init() {
	env := os.Getenv("ENV")
	if env == "" {
		env = "ldev"
	}

	configFile := "/app/config/" + env + ".yml"
	Load(configFile)
}
