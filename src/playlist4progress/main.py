from typing import TextIO

import bs4
import click


@click.command()
@click.option("--file", type=click.File("r"), default="playlist.xspf", help="File of playlist.")
@click.argument("index", type=int)
def cli(file: TextIO, index: int) -> None:
    """Prints the total length of a playlist and the combined length of the first n tracks."""
    file_text = "\n".join(file.readlines())

    soup = bs4.BeautifulSoup(file_text, "xml")
    lengths = [int(track.duration.string)/1000 for track in soup.playlist.trackList.find_all("track")]

    # get number of seconds and calculate progress
    total_seconds = sum(lengths)
    part_seconds = sum(lengths[0:index])
    progress = part_seconds / total_seconds

    # calculate accurate number of hours, minutes, and seconds
    total_minutes = total_seconds // 60
    total_hours = total_minutes // 60

    total_seconds = total_seconds % 60
    total_minutes = total_minutes % 60

    part_minutes = part_seconds // 60
    part_hours = part_minutes // 60

    part_seconds = part_seconds % 60
    part_minutes = part_minutes % 60

    print(f"Part length:  {part_hours:02.0f}:{part_minutes:02.0f}:{part_seconds:02.0f}")
    print(f"Total length: {total_hours:02.0f}:{total_minutes:02.0f}:{total_seconds:02.0f}")
    print(f"Progress:     {progress * 100:.2f}%")
