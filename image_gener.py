import argparse
import os

import openai
import requests


def logger(message, log_file="output.md"):
    """
    This function logs error messages to a specified log file.

    Args:
        message (str): The error message to log.
        log_file (str): The file to log the error message to.
    """
    print(message)
    with open(log_file, "a") as output_file:
        output_file.write(f"{message}\n")


def read_file(file_path, error_message):
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return file.read()
    except FileNotFoundError:
        logger(error_message)
        exit(1)


def main():
    parser = argparse.ArgumentParser(
        prog="send_query_to_ai",
        description="image_creator",
        epilog="send_query_to_ai Help",
    )
    parser.add_argument(
        "-s", "--story_id", action="store", help="story_id", required=True
    )
    parser.add_argument(
        "-e", "--scene_id", action="store", help="scene_id", required=True
    )
    parser.add_argument(
        "-k", "--api_key", action="store", help="api_key", required=True
    )
    args = parser.parse_args()

    api_key = args.api_key
    if len(api_key) == 0:
        logger("api key is null")
        exit(1)

    # Read the image prompt from the command file
    image_prompt = read_file("command.txt", "command file could not be found")

    # Read the story
    story_path = f"docs/stories/{args.story_id}.txt"
    story = read_file(story_path, "story could not be found")

    # Edit the prompt
    image_prompt_phase1 = image_prompt.replace("<<<WHOLE_STORY_HERE>>>", story)
    image_prompt_phase2 = image_prompt_phase1.replace(
        "<<<SCENE_NUMBER_HERE>>>", str(args.scene_id)
    )


    try:
        # Call OpenAI's API to generate the image using DALL-E 3
        response = openai.Image.create(
            model="dall-e-3",  # Specify DALL-E 3 model
            prompt=image_prompt_phase2,
            size="1792x1024",  # Free tier supports lower resolutions
            n=1,  # Generate a single image
            api_key=api_key,  # Pass the API key
        )

        logger(f"response: {str(response)}")

        # Get the image URL from the response
        image_url = response["data"][0]["url"]

        img_data = requests.get(image_url).content
        with open(f"story_{args.story_id}_scene_{args.scene_id}.png", "wb") as handler:
            handler.write(img_data)
    except openai.error.OpenAIError as e:
        logger(f"OpenAI API error: {str(e)}")
        exit(2)
    except requests.RequestException as e:
        logger(f"Request error: {str(e)}")
        exit(1)


if __name__ == "__main__":
    main()
