# parashot-commentaries
Podcast RSS Feed

## Pronunciation Override
To change the pronunciation of a word, add it to the pronunciation-guide.json file and run `bin/build`.
`bin/order` re-orders the pronunciation guide and removes duplicates.
Each key represents a word and the corresponding value it's International Phonetic Alphabet representation.
The regenerated lexicons files can be found in the lexicons directory.

## Publish New Episode
1. Create new branch
    * `git checkout -b new-branch-name`
2. Add parashahot text to `tmp/input.txt`
3. Run `bin/pollycast`
4. Verify the audio in `tmp/output.mp3`
5. Add intro/outro to audio file and place in `audio` directory
6. Add new item to `commentary.json`
7. Run `bin/generate`
8. Open PR
    * `git add -A`
    * `git commit -m "Message goes here"`
    * `git push`
    * Navigate to GitHub repo and click green "Open PR" button
9. Merge PR
