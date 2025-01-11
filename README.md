# parashot-commentaries
Podcast RSS Feed

## Install
* Ensure Ruby in installed
* `brew install ffmpeg`
* `bundle install`

## Pronunciation Override
To change the pronunciation of a word, add it to the pronunciation-guide.json file and run `bin/build`.
`bin/order` re-orders the pronunciation guide and removes duplicates.
Each key represents a word and the corresponding value it's International Phonetic Alphabet representation.
The regenerated lexicons files can be found in the lexicons directory.

## Publish New Episode

Here is a guide to publishing a new episode of the podcast. The process is largely automated to minimize manual steps.

### 1. Prepare the Episode Text
1. Navigate to your project directory in a newly-opened Terminal (assuming the repo is on your Desktop):
   ```bash
   cd Desktop/parashot-commentaries
   ```
1. Open the `tmp/input.txt` file in a text editor:
   ```bash
   open tmp/input.txt
   ```
1. Paste the text of the parashah into the file.
1. Save and close the file.

### 2. Run the Publishing Script
1. Run the publishing script:
   ```bash
   bin/publish_episode
   ```
1. Follow the prompts to enter:
   - Episode title (e.g., 'Bereshit', 'Noach')
   - Description (e.g., 'Commentary on Torah portion "Bereshit" (Genesis 1:1-6:8)')
   - Publish date (YYYY-MM-DD format)

The script will automatically:
- Generate the audio file using AWS Polly
- Add intro and outro to the audio
- Place the final audio file in the correct location
- Update commentary.json with the new episode
- Generate the RSS feed
- Create a new Git branch
- Commit all changes
- Push to GitHub
- Return to the main branch

### 3. Complete the Publication
1. Go to the [GitHub repository](https://github.com/jaysonvirissimo/parashot-commentaries) in your browser
2. You should see a notification about your recently pushed branch
3. Click the "Compare & pull request" button
4. Review the changes and create the pull request
5. Once the tests pass, merge the pull request

### 4. Celebrate! 🎉
Your new episode is now live and ready for listeners!

## Troubleshooting
- If you see "permission denied" when running the script, make it executable:
  ```bash
  chmod +x bin/publish-episode
  ```
- Ensure your AWS credentials are set up:
  ```bash
  echo 'export AWS_ACCESS_KEY_ID=your_access_key_id_here' >> ~/.zshrc
  echo 'export AWS_SECRET_ACCESS_KEY=your_secret_access_key_here' >> ~/.zshrc
  source ~/.zshrc
  ```
