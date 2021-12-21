// #![allow(
use std::collections::HashSet;
use std::ops::Range;

use anyhow::anyhow;
use anyhow::Result;
use itertools::Itertools;

fn main() -> Result<()> {
    let mut puzzle = include_str!("../../data/20.input").lines();
    let map = puzzle
        .next()
        .ok_or_else(|| anyhow!("Malformed input"))?
        .chars()
        .map(|c| match c {
            '.' => false,
            '#' => true,
            _ => panic!("OH NO CHAT"),
        })
        .collect_vec();

    // ignore the empty line
    puzzle.next();

    let input = puzzle.map(|l| l.chars().collect_vec()).collect_vec();
    let size = input.len() as i32;

    // println!("{:?}", input);

    // I want a map of where we have '#'...
    let mut octothorpes = HashSet::new();
    for x in 0..size {
        for y in 0..size {
            if input[x as usize][y as usize] == '#' {
                octothorpes.insert((x, y));
            }
        }
    }

    for count in 0..50 {
        if count == 2 {
            println!("Part 1: {}", octothorpes.len());
        }

        octothorpes = step(&map, size, count + 1, &octothorpes, false);
    }

    println!("Part 2: {:?}", octothorpes.len());

    Ok(())
}

fn step(
    map: &Vec<bool>,
    size: i32,
    count: i32,
    octothorpes: &HashSet<(i32, i32)>,
    _print: bool,
) -> HashSet<(i32, i32)> {
    let min_size = 0 - count;
    let max_size = size + count;

    // println!("Checking from {} -> {}", min_size, max_size);

    // count = 1, that's the first thing
    // 1 -> everything is 0
    // 2 -> everything is 1
    // 3 -> everything is 0
    // 4 -> everything is 1
    let outside = if !map[0] {
        0
    } else {
        if count % 2 == 0 {
            1
        } else {
            0
        }
    };

    let mut new_octos = HashSet::new();
    for x in min_size - 2..=max_size + 2 {
        for y in min_size - 2..=max_size + 2 {
            let num = get_mapped(&octothorpes, x, y, min_size..max_size, outside);

            if map[num as usize] {
                new_octos.insert((x, y));
            }
        }
    }

    new_octos
}

pub fn get_mapped(
    octothorpes: &HashSet<(i32, i32)>,
    x: i32,
    y: i32,
    range: Range<i32>,
    default: u32,
) -> u32 {
    let mut translated = 0;
    for x_offset in [-1, 0, 1] {
        for y_offset in [-1, 0, 1] {
            translated <<= 1;
            let new_x = x + x_offset;
            let new_y = y + y_offset;
            if octothorpes.contains(&(new_x, new_y)) {
                translated += 1;
            } else if !range.contains(&x) || !range.contains(&y) {
                translated += default;
            }
        }
    }

    translated
}
