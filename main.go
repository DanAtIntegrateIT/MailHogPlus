package main

import (
	"flag"
	"fmt"
	"io"
	stdlog "log"
	"os"
	"path/filepath"
	"time"

	gohttp "net/http"

	"github.com/gorilla/pat"
	"github.com/ian-kent/go-log/log"
	"github.com/mailhog/MailHog-Server/api"
	cfgapi "github.com/mailhog/MailHog-Server/config"
	"github.com/mailhog/MailHog-Server/smtp"
	"github.com/mailhog/MailHog-UI/assets"
	cfgui "github.com/mailhog/MailHog-UI/config"
	"github.com/mailhog/MailHog-UI/web"
	cfgcom "github.com/mailhog/MailHog/config"
	"github.com/mailhog/http"
	"github.com/mailhog/mhsendmail/cmd"
	"golang.org/x/crypto/bcrypt"
)

var apiconf *cfgapi.Config
var uiconf *cfgui.Config
var comconf *cfgcom.Config
var exitCh chan int
var version string

func configureLogging() {
	logFilePath := resolveLogFilePath()

	if err := rotateLogFileIfOlderThan(logFilePath, 24*time.Hour); err != nil {
		log.Printf("Unable to rotate log file %q: %s", logFilePath, err)
	}

	file, err := os.OpenFile(logFilePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Printf("Unable to open log file %q: %s", logFilePath, err)
		return
	}

	stdlog.SetOutput(io.MultiWriter(os.Stdout, file))
	log.Printf("Writing logs to %s", logFilePath)
}

func resolveLogFilePath() string {
	logFilePath := os.Getenv("MH_LOG_FILE")
	if logFilePath == "" {
		logFilePath = "mailhogplus.log"
	}
	if filepath.IsAbs(logFilePath) {
		return logFilePath
	}
	absPath, err := filepath.Abs(logFilePath)
	if err != nil || absPath == "" {
		return logFilePath
	}
	return absPath
}

func rotateLogFileIfOlderThan(logFilePath string, maxAge time.Duration) error {
	info, err := os.Stat(logFilePath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	if time.Since(info.ModTime()) < maxAge {
		return nil
	}

	rotatedPath := fmt.Sprintf("%s.%s", logFilePath, info.ModTime().Format("20060102"))
	if err := os.Remove(rotatedPath); err != nil && !os.IsNotExist(err) {
		return err
	}
	if err := os.Rename(logFilePath, rotatedPath); err != nil {
		return err
	}

	entries, err := findOlderRotatedLogFiles(logFilePath, time.Now().Add(-maxAge))
	if err != nil {
		return err
	}
	for _, path := range entries {
		if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
			return err
		}
	}
	return nil
}

func findOlderRotatedLogFiles(basePath string, cutoff time.Time) ([]string, error) {
	matches, err := filepath.Glob(basePath + ".*")
	if err != nil {
		return nil, err
	}
	old := make([]string, 0, len(matches))
	for _, path := range matches {
		info, statErr := os.Stat(path)
		if statErr != nil {
			if os.IsNotExist(statErr) {
				continue
			}
			return nil, statErr
		}
		if info.ModTime().Before(cutoff) {
			old = append(old, path)
		}
	}
	return old, nil
}

func configure() {
	cfgcom.RegisterFlags()
	cfgapi.RegisterFlags()
	cfgui.RegisterFlags()
	flag.Parse()
	apiconf = cfgapi.Configure()
	uiconf = cfgui.Configure()
	comconf = cfgcom.Configure()

	apiconf.WebPath = comconf.WebPath
	uiconf.WebPath = comconf.WebPath
}

func main() {
	if len(os.Args) > 1 && (os.Args[1] == "-version" || os.Args[1] == "--version") {
		fmt.Println("MailHogPlus version: " + version)
		os.Exit(0)
	}

	if len(os.Args) > 1 && os.Args[1] == "sendmail" {
		args := os.Args
		os.Args = []string{args[0]}
		if len(args) > 2 {
			os.Args = append(os.Args, args[2:]...)
		}
		cmd.Go()
		return
	}

	if len(os.Args) > 1 && os.Args[1] == "bcrypt" {
		var pw string
		if len(os.Args) > 2 {
			pw = os.Args[2]
		} else {
			// TODO: read from stdin
		}
		b, err := bcrypt.GenerateFromPassword([]byte(pw), 4)
		if err != nil {
			log.Fatalf("error bcrypting password: %s", err)
			os.Exit(1)
		}
		fmt.Println(string(b))
		os.Exit(0)
	}

	configure()
	configureLogging()

	if comconf.AuthFile != "" {
		http.AuthFile(comconf.AuthFile)
	}

	exitCh = make(chan int)
	if uiconf.UIBindAddr == apiconf.APIBindAddr {
		cb := func(r gohttp.Handler) {
			web.CreateWeb(uiconf, r.(*pat.Router), assets.Asset)
			api.CreateAPI(apiconf, r.(*pat.Router))
		}
		go http.Listen(uiconf.UIBindAddr, assets.Asset, exitCh, cb)
	} else {
		cb1 := func(r gohttp.Handler) {
			api.CreateAPI(apiconf, r.(*pat.Router))
		}
		cb2 := func(r gohttp.Handler) {
			web.CreateWeb(uiconf, r.(*pat.Router), assets.Asset)
		}
		go http.Listen(apiconf.APIBindAddr, assets.Asset, exitCh, cb1)
		go http.Listen(uiconf.UIBindAddr, assets.Asset, exitCh, cb2)
	}
	go smtp.Listen(apiconf, exitCh)

	<-exitCh
	log.Printf("Received exit signal")
}

/*

Add some random content to the end of this file, hopefully tricking GitHub
into recognising this as a Go repo instead of Makefile.

A gopher, ASCII art style - borrowed from
https://gist.github.com/belbomemo/b5e7dad10fa567a5fe8a

          ,_---~~~~~----._
   _,,_,*^____      _____``*g*\"*,
  / __/ /'     ^.  /      \ ^@q   f
 [  @f | @))    |  | @))   l  0 _/
  \`/   \~____ / __ \_____/    \
   |           _l__l_           I
   }          [______]           I
   ]            | | |            |
   ]             ~ ~             |
   |                            |
    |                           |

*/
