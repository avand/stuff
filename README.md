# Stuff

Stuff is a *very* simple little Ruby command line app designed to publish the things you plan to do today.

I like to use [Things](http://culturedcode.com/things/) to manage my to-dos. It's simpler and faster than any ticketing system. However, because it's local, no one on my team has visibilty to what I'm working on.

Stuff just reads in the Things XML database and pulls in any to-dos marked Today for the areas you specify.

# Usage

There's not to much to it. Just clone this code and run:

    $> ruby stuff.rb "One Area" "Another Area"

That'll get you HTML to `STDOUT`. Just pipe it to a file:

    $> ruby stuff.rb "One Area" "Another Area" > ~/Dropbox/Public/today.html

If you use [Dropbox](http://dropbox.com), you're done. Just share the URL to that file with your teammates. Otherwise, you'll have to figure out a way to get that file on a public server somewhere. You're on your own there.

Schedule this to run regularly with cron. There's an example crontab to help you get started.
