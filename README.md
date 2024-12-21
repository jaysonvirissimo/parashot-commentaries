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

Here is a detailed guide to publishing a new episode of the podcast, tailored for macOS users with minimal terminal experience. Follow each step carefully.

### 1. Create a New Branch
Branches help keep your changes organized and separate from the main project. Here’s how to create one:

1. Open the **Terminal** application (you can find it by searching "Terminal" in Spotlight).
2. Navigate to your project directory in the terminal. If your project is located on your `Desktop`, type:
   ```bash
   cd ~/Desktop/parashot-commentaries
   ```
3. Create a new branch by running:
   ```bash
   git checkout -b new-branch-name
   ```
   Replace `new-branch-name` with a name that describes your changes (e.g., `episode-12`).
4. Confirm the branch has been created and switched to by running:
   ```bash
   git branch
   ```
   The branch name you just created should be highlighted with an asterisk (*).

### 2. Add Parashahot Text to `tmp/input.txt`
This is the text that will be converted to audio for the episode.

1. Open the `tmp/input.txt` file in a text editor. On macOS, you can use **TextEdit** or another editor:
   ```bash
   open tmp/input.txt
   ```
2. Paste the text of the parashah into the file.
3. Save and close the file.

### 3. Generate Audio with AWS Polly
AWS Polly will convert the text to audio.

1. In the terminal, run:
   ```bash
   bin/pollycast
   ```
2. Wait for the script to process the text. When it’s complete, it will provide a public URL to download the audio file.
3. Open the provided URL in your browser to download and verify the audio.
4. The generated audio will also be saved in the S3 bucket and can be accessed from the URL printed by the script.

### 4. Add Intro/Outro and Place in `audio` Directory
Use the new `bin/pad_audio` script to add the intro and outro to your episode audio.

1. Ensure the intro file (`audio/intro.mp3`) and outro file (`audio/outro.m4a`) exist in the `audio` directory.
2. Run the `pad_audio` script with the path to your audio file:
   ```bash
   bin/pad_audio audio/episode-N.mp3
   ```
   Replace `episode-N.mp3` with the filename of your generated audio.
3. The padded audio file will be saved in the `audio` directory with the suffix `_padded` (e.g., `episode-N_padded.mp3`).

### 5. Add a New Item to `commentary.json`
This file contains metadata for the podcast episodes.

1. Open `commentary.json` in your text editor:
   ```bash
   open commentary.json
   ```
2. Add a new entry for the episode. Use the following format:
   ```json
   {
       "title": "Episode Title",
       "description": "Brief description of the episode",
       "audioFile": "audio/episode-N_padded.mp3",
       "date": "YYYY-MM-DD"
   }
   ```
   Replace the placeholders with the correct information.
3. Save and close the file.

### 6. Generate Updated Files
Update the RSS feed and other generated files by running:
```bash
bin/generate
```

### 7. Open a Pull Request (PR)
A PR is how you propose changes to the main repository.

1. Add all your changes to Git:
   ```bash
   git add -A
   ```
2. Commit the changes with a descriptive message:
   ```bash
   git commit -m "Publish haftara N"
   ```
   Replace `N` with the parasha/haftara name.
3. Push your branch to GitHub:
   ```bash
   git push
   ```
4. Open the GitHub repository in your browser. You can find it by navigating to the project’s URL (e.g., `https://github.com/jaysonvirissimo/parashot-commentaries`).
5. Click the green **Open PR** button and follow the prompts to create a pull request.

### 8. Merge the Pull Request
1. Once the PR has been reviewed and approved, click the **Merge PR** button on GitHub.
2. Confirm the merge and ensure the changes are added to the main branch.

### 9. Celebrate!
Your new episode is now live and ready for listeners!
