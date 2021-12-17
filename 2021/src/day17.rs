use std::collections::HashSet;

use anyhow::Result;

fn max_x(vel_x: i64) -> i64 {
    vel_x * (vel_x + 1) / 2
}

fn quadratic(a: i64, b: i64, c: i64) -> Option<i64> {
    let sqrt = (-a as f64 + ((b * b) as f64 - (4 * a * c) as f64).sqrt()) / (2 * a) as f64;

    (sqrt.fract() == 0f64).then(|| sqrt as i64)
}

fn quadratic_is_integer(target: i64) -> Option<i64> {
    let sqrt = (-1f64 + (1f64 + 8f64 * target as f64).sqrt()) / 2f64;
    if sqrt.fract() == 0f64 {
        println!("Time: {}", sqrt);
        quadratic(1, 1, -2 * target)
    } else {
        None
    }
}

#[derive(Debug)]
struct InfoX {
    velocity: i64,
    time: i64,
}

fn time_til_x_target(v_x: i64, target_x: i64) -> Option<InfoX> {
    if (v_x * (v_x + 1) / 2) < target_x {
        None
    } else {
        let mut distance = 0;
        let mut current_v_x = v_x;
        let mut time = 0;
        while distance < target_x && current_v_x != 0 {
            time += 1;
            distance += current_v_x;
            current_v_x -= 1;
        }

        if distance == target_x {
            Some(InfoX {
                velocity: current_v_x,
                time,
            })
        } else {
            None
        }
    }
}

fn main() -> Result<()> {
    // x=20..30, y=-10..-5
    // target area: x=201..230, y=-99..-65
    let mut max_v_y = i64::MIN;

    // let x_min = 20;
    // let x_max = 30;
    // let y_min = -10;
    // let y_max = -5;

    let x_min = 201;
    let x_max = 230;
    let y_min = -99;
    let y_max = -65;

    let mut good_stuffs = HashSet::new();
    for target_x in x_min..=x_max {
        for v_x in 1..=target_x {
            match time_til_x_target(v_x, target_x) {
                Some(x_info) => {
                    let r = match x_info.velocity {
                        0 => x_info.time..1000,
                        _ => x_info.time..x_info.time + 1,
                    };

                    for test_time in r.rev() {
                        // TODO: Could figure out what the max y val should be here.
                        for v_y in y_min..1000 {
                            let mut current_v_y = v_y;
                            let mut y = 0;
                            for _ in 0..test_time {
                                y += current_v_y;
                                current_v_y -= 1;
                            }

                            if y_max >= y && y >= y_min {
                                good_stuffs.insert((v_x, v_y));

                                if v_y > max_v_y {
                                    max_v_y = v_y;
                                }
                            }
                        }
                    }
                }
                None => continue,
            }
        }
    }

    let mut height = 0;
    let mut current_v_y = max_v_y;
    loop {
        height = height + current_v_y;
        current_v_y -= 1;

        if current_v_y == 0 {
            break;
        }
    }

    println!("Max V Y: {}", max_v_y);
    println!("New height?: {}", height);
    println!("Good stuffs: {}", good_stuffs.len());
    // dbg!(good_stuffs);

    // TODO: Explain cool answer for part 1

    Ok(())
}
