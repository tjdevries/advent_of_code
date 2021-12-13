use std::collections::HashMap;

use itertools::Itertools;

fn main() {
    println!(
        "Part 1: {}",
        include_str!("../data/10.example")
            .lines()
            .fold(0, |acc, line| {
                let opener = vec!['[', '(', '{', '<'];
                let mut closer = HashMap::new();
                closer.insert(']', '[');
                closer.insert(')', '(');
                closer.insert('}', '{');
                closer.insert('>', '<');

                let mut stack = Vec::new();
                for c in line.chars() {
                    if opener.contains(&c) {
                        stack.push(c);
                    } else {
                        let last = stack.last().unwrap();
                        let complete = closer.get(&c).unwrap();

                        if last == complete {
                            stack.pop();
                        } else {
                            if c == ')' {
                                return acc + 3;
                            } else if c == ']' {
                                return acc + 57;
                            } else if c == '}' {
                                return acc + 1197;
                            } else if c == '>' {
                                return acc + 25137;
                            } else {
                                panic!("Uhhmmm...");
                            }
                        }
                    }
                }

                acc
            })
    );

    println!(
        "Part 2: {}",
        include_str!("../data/10.example")
            .lines()
            .fold(0, |acc, line| {
                let opener = HashMap::new();
                closer.insert('[', ']');
                closer.insert('(', ')');
                closer.insert('{', '}');
                closer.insert('<', '>');

                let mut closer = HashMap::new();
                closer.insert(']', '[');
                closer.insert(')', '(');
                closer.insert('}', '{');
                closer.insert('>', '<');

                let mut stack = Vec::new();
                for c in line.chars() {
                    if opener.contains(&c) {
                        stack.push(c);
                    } else {
                        let last = stack.last().unwrap();
                        let complete = closer.get(&c).unwrap();

                        if last == complete {
                            stack.pop();
                        } else {
                            if c == ')' {
                                return acc + 3;
                            } else if c == ']' {
                                return acc + 57;
                            } else if c == '}' {
                                return acc + 1197;
                            } else if c == '>' {
                                return acc + 25137;
                            } else {
                                panic!("Uhhmmm...");
                            }
                        }
                    }
                }

                acc
            })
    );
}
