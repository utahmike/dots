---
description: Summarize a URL and save to Obsidian vault resources
argument-hint: <url>
allowed-tools: WebFetch, Write, Bash, Glob
---

Summarize the following URL and save it to my Obsidian vault:

**URL**: $ARGUMENTS

## Instructions

### YouTube Detection

If the URL matches `youtube.com/watch`, `youtu.be/`, or `youtube.com/shorts/`, follow the **YouTube Flow** below. Otherwise, continue with the **Standard Flow**.

---

## YouTube Flow

### 1. Run yt-dlp to get metadata, thumbnail, and transcript

```bash
yt-dlp --skip-download \
  --print "%(id)s" \
  --print "%(title)s" \
  --print "%(channel)s" \
  --print "%(channel_url)s" \
  --print "%(duration>%H:%M:%S)s" \
  --print "%(upload_date>%Y-%m-%d)s" \
  --print "%(view_count)s" \
  --print "%(like_count)s" \
  --print "%(tags)j" \
  --print "%(chapters)j" \
  --print "%(description)s" \
  --write-thumbnail --convert-thumbnails jpg \
  --write-auto-sub --sub-lang "en" --sub-format vtt \
  --no-playlist \
  -o "/Users/mjc/Documents/aspengrove/resources/images/YYYY-MM-DD-%(id)s" \
  "<url>"
```
(Replace `YYYY-MM-DD` with today's date)

### 2. Parse the output

The command outputs one field per line:
1. `id` - Video ID (used in filenames)
2. `title` - Video title
3. `channel` - Channel/author name
4. `channel_url` - Channel URL (e.g., https://youtube.com/@ChannelHandle)
5. `duration` - Pre-formatted as "H:MM:SS"
6. `upload_date` - Pre-formatted as "YYYY-MM-DD"
7. `view_count` - Number of views
8. `like_count` - Number of likes
9. `tags` - JSON array of creator's tags
10. `chapters` - JSON array of chapters (may be empty)
11. `description` - Video description (multi-line, last field)

### 3. Generate category

From the tags and title, derive a single-word high-level category (e.g., horology, home-automation, cryptography, programming, cooking, gaming, electronics, woodworking).

### 4. Read and process transcript

- yt-dlp writes the transcript to: `YYYY-MM-DD-VIDEO_ID.en.vtt`
- Parse the VTT file to extract plain text (strip timestamps and formatting)
- Use the transcript to generate the summary and key points
- Delete the VTT file after extraction
- If no transcript is available, fall back to summarizing from title + description

### 5. Create the output file

Save to `/Users/mjc/Documents/aspengrove/resources/` with filename `YYYY-MM-DD-VIDEO_ID.md` (using the video ID from step 2, e.g., `2024-12-20-dQw4w9WgXcQ.md`).

### 6. Use this exact format for YouTube:

```markdown
---
title: "Video Title"
type: resource
url: [original URL]
domain: youtube.com
author: Channel Name
author_url: https://youtube.com/@ChannelHandle
content_type: video
category: horology
duration: "12:34"
published: 2024-03-15
views: 1234567
likes: 45000
topics: [creator-tag-1, creator-tag-2, creator-tag-3]
tags: [resource, youtube, creator-tag-1, creator-tag-2, ai-generated-tag-1, ai-generated-tag-2, ai-generated-tag-3, ai-generated-tag-4]
created: YYYY-MM-DD
image: "images/YYYY-MM-DD-VIDEO_ID.jpg"
summary: "AI-generated 1-2 sentence summary from transcript content."
---

![](images/YYYY-MM-DD-VIDEO_ID.jpg)

## Source

[Video Title](original-url) by [Channel Name](https://youtube.com/@ChannelHandle)

## Overview

2-3 sentence summary generated from the transcript, explaining what the video covers and its key message.

## Key Points

- Key takeaway 1 (from transcript)
- Key takeaway 2 (from transcript)
- Additional points from actual video content...

## Chapters

- [0:00 - Introduction](https://youtube.com/watch?v=VIDEO_ID&t=0)
- [2:30 - Main Topic](https://youtube.com/watch?v=VIDEO_ID&t=150)

## Details

[Video description content - may contain links and resources mentioned by creator]
```

**Notes for YouTube:**
- Omit the `Chapters` section entirely if the video has no chapters
- Omit `likes`/`views` properties if unavailable
- `topics`: Use the creator's tags (lowercase, hyphen-separated)
- `tags`: Combine `resource`, `youtube`, creator's tags, plus 4-5 AI-generated tags based on the summary (all lowercase, hyphen-separated)
- The `image` property uses a relative path from the resources folder

### 7. Confirm completion

Show the filepath of the created markdown file and the downloaded thumbnail.

---

## Standard Flow (non-YouTube URLs)

1. **Fetch the URL** using WebFetch to get the full content and identify any featured/hero image (og:image, main article image, or thumbnail)

2. **Extract metadata**:
   - Title of the page/article
   - Author (if available, otherwise omit)
   - Domain (extract from URL)
   - Content type: article, video, documentation, tutorial, or reference
   - Estimate reading time based on content length
   - Featured image URL (og:image or main article image)

3. **Download the image** (if found):
   - Save to `/Users/mjc/Documents/aspengrove/resources/images/`
   - Filename format: `YYYY-MM-DD-domain.ext` (matching the markdown file, with appropriate image extension)
   - If a file with that name exists, append a number: `YYYY-MM-DD-domain-2.ext`
   - Use curl to download: `curl -L -o /path/to/image.jpg "image-url"`
   - If no image is found or download fails, omit the image property from frontmatter

4. **Generate a comprehensive summary**:
   - Overview: 2-3 sentences capturing the main point
   - Key Points: 5-8 bulleted takeaways
   - Details: Notable quotes, examples, or important specifics worth preserving

5. **Identify 2-5 topic tags** based on the content (lowercase, hyphenated)

6. **Create the output file** at `/Users/mjc/Documents/aspengrove/resources/` with:
   - Filename format: `YYYY-MM-DD-domain.md` (use today's date, extract domain without www/subdomain)
   - If a file with that name already exists, append a number: `YYYY-MM-DD-domain-2.md`

7. **Use this exact format**:

```markdown
---
title: "Extracted Title"
type: resource
url: [the original URL]
domain: example.com
author: Author Name
content_type: article
reading_time: "X min"
topics: [topic1, topic2, topic3]
tags: [resource, domain-name]
created: YYYY-MM-DD
image: "images/YYYY-MM-DD-domain.jpg"
summary: "Brief 1-2 sentence summary for table preview"
---

![](images/YYYY-MM-DD-domain.jpg)

## Overview

2-3 sentence comprehensive overview of what this resource covers and why it matters.

## Key Points

- First key takeaway
- Second key takeaway
- Additional important points

## Details

Notable quotes, examples, code snippets, or deeper details worth preserving from the original content.

## Source

[Original Title](original-url)
```

Note: Only include the `image` property and the `![](images/...)` embed if an image was successfully downloaded. Use the relative path from the resources folder (e.g., `images/2024-12-19-hodinkee.jpg`).

8. **After writing**, confirm the file was created and show the filepath (and image path if downloaded).
