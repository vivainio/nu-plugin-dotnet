#!/usr/bin/env nu

# Practical Example: User-Friendly Generic Syntax
print "🚀 Practical Example: Managing a Book Library"
print "============================================="
print ""

print "Before: Using complex .NET syntax"
print "---------------------------------"
print 'let $books = dn new "System.Collections.Generic.Dictionary`2[System.String,System.Collections.Generic.List`1[System.String]]"'
print ""

print "After: Using user-friendly syntax"
print "---------------------------------"
print 'let $books = dn new "Dictionary<string, List<string>>"'
print ""

print "Let's build a book library with the new syntax:"
print "==============================================="

# Create a dictionary to store books by genre
let $books = dn new "Dictionary<string, List<string>>"
print $"📚 Book library created: ($books)"

# Create lists for different genres
let $fiction = dn new "List<string>"
let $scifi = dn new "List<string>"
let $mystery = dn new "List<string>"

# Add fiction books
$fiction | dn call "Add" "The Great Gatsby"
$fiction | dn call "Add" "To Kill a Mockingbird"
$fiction | dn call "Add" "1984"

# Add sci-fi books
$scifi | dn call "Add" "Dune"
$scifi | dn call "Add" "Foundation"
$scifi | dn call "Add" "The Hitchhiker's Guide to the Galaxy"

# Add mystery books
$mystery | dn call "Add" "The Maltese Falcon"
$mystery | dn call "Add" "The Big Sleep"
$mystery | dn call "Add" "Gone Girl"

# Add genres to the main dictionary
$books | dn call "Add" "Fiction" $fiction
$books | dn call "Add" "Science Fiction" $scifi
$books | dn call "Add" "Mystery" $mystery

print ""
print "Library Statistics:"
print "------------------"
let $genreCount = $books | dn get "Count"
print $"Genres in library: ($genreCount)"

let $fictionCount = $fiction | dn get "Count"
let $scifiCount = $scifi | dn get "Count"
let $mysteryCount = $mystery | dn get "Count"

print $"Fiction books: ($fictionCount)"
print $"Sci-Fi books: ($scifiCount)"
print $"Mystery books: ($mysteryCount)"

print ""
print "Sample Book Lookup:"
print "------------------"
let $scifiBooks = $books | dn call "get_Item" "Science Fiction"
let $firstScifiBook = $scifiBooks | dn call "get_Item" 0
print $"First Sci-Fi book: ($firstScifiBook)"

print ""
print "✨ The new syntax makes generic .NET collections much easier to work with!"
print "   Compare 'Dictionary<string, List<string>>' vs"
print '   "System.Collections.Generic.Dictionary`2[System.String,System.Collections.Generic.List`1[System.String]]"' 