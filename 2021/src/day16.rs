#![allow(dead_code)]
#![recursion_limit = "1000"]

use std::str::Chars;

use anyhow::Result;
use itertools::Itertools;

#[derive(Debug)]
enum TypeId {
    LiteralValue,
    Operator(u64),
}

fn to_num(chars: &mut Chars, size: usize) -> Result<u64> {
    Ok(u64::from_str_radix(&chars.take(size).collect::<String>(), 2).unwrap())
}

fn get_version(chars: &mut Chars) -> Result<u64> {
    to_num(chars, 3)
}

fn get_type_id(chars: &mut Chars) -> Result<TypeId> {
    Ok(match to_num(chars, 3)? {
        4 => TypeId::LiteralValue,
        t => TypeId::Operator(t),
    })
}

#[derive(Debug)]
enum PacketContents {
    LiteralValue { result: u64 },
    VariableLength { length: u64, packets: Vec<Packet> },
    FixedLength { packets: Vec<Packet> },
}

#[derive(Debug)]
struct Packet {
    length: u64,
    version: u64,
    type_id: TypeId,
    contents: PacketContents,
}

fn gt_iterator<T>() -> fn(T) -> u64
where
    T: Iterator<Item = u64>,
{
    |mut iter: T| {
        let first = iter.next().unwrap();
        let second = iter.next().unwrap();

        (first > second) as u64
    }
}

fn lt_iterator<T>() -> fn(T) -> u64
where
    T: Iterator<Item = u64>,
{
    |mut iter: T| {
        let first = iter.next().unwrap();
        let second = iter.next().unwrap();

        (first < second) as u64
    }
}

fn eq_iterator<T>() -> fn(T) -> u64
where
    T: Iterator<Item = u64>,
{
    |mut iter: T| {
        let first = iter.next().unwrap();
        let second = iter.next().unwrap();

        (first == second) as u64
    }
}

impl Packet {
    fn eval(&self) -> u64 {
        match self.type_id {
            TypeId::LiteralValue => match self.contents {
                PacketContents::LiteralValue { result } => result,
                _ => panic!("Can't have this, literal and literal only"),
            },
            TypeId::Operator(mode) => {
                let op = match mode {
                    0 => Iterator::sum,
                    1 => Iterator::product,
                    2 => |iter| Iterator::min(iter).unwrap(),
                    3 => |iter| Iterator::max(iter).unwrap(),
                    5 => gt_iterator(),
                    6 => lt_iterator(),
                    7 => eq_iterator(),
                    _ => unimplemented!("Mode: {}", mode),
                };

                op(match &self.contents {
                    PacketContents::VariableLength { packets, .. }
                    | PacketContents::FixedLength { packets } => packets,
                    _ => panic!("Can't have this, no literals allowed"),
                }
                .iter()
                .map(|p| p.eval()))
            }
        }
    }
}

fn parse_packet(chars: &mut Chars) -> Result<Packet> {
    let mut length = 6;
    let version = get_version(chars)?;
    let type_id = get_type_id(chars)?;

    let contents = match type_id {
        TypeId::LiteralValue => {
            let mut numbers = String::new();
            while chars.next().unwrap() != '0' {
                length += 5;
                numbers.extend(chars.take(4));
            }

            length += 5;
            numbers.extend(chars.take(4));

            PacketContents::LiteralValue {
                result: u64::from_str_radix(&numbers, 2)?,
            }
        }
        TypeId::Operator(_) => {
            let length_typ_id = chars.next().unwrap();
            length += 1;

            match length_typ_id {
                '0' => {
                    let packet_length = to_num(chars, 15)?;
                    length += 15 + packet_length;

                    let mut packets = Vec::new();
                    let mut len = 0;
                    while len < packet_length {
                        let subpacket = parse_packet(chars)?;

                        len += subpacket.length;
                        packets.push(subpacket);
                    }

                    PacketContents::VariableLength {
                        length: packet_length,
                        packets,
                    }
                }
                '1' => {
                    let num_packets = to_num(chars, 11)?;
                    length += 11;

                    let mut packets = Vec::with_capacity(num_packets as usize);
                    for _ in 0..num_packets {
                        let subpacket = parse_packet(chars)?;

                        length += subpacket.length;
                        packets.push(subpacket);
                    }

                    PacketContents::FixedLength { packets }
                }
                _ => unreachable!(),
            }
        }
    };

    Ok(Packet {
        length,
        version,
        type_id,
        contents,
    })
}

fn add_versions(packet: &Packet) -> u64 {
    packet.version
        + match &packet.contents {
            PacketContents::LiteralValue { .. } => 0,
            PacketContents::VariableLength { packets, .. }
            | PacketContents::FixedLength { packets } => {
                packets.iter().map(|p| add_versions(p)).sum()
            }
        }
}

fn part_1(s: &str) -> Result<u64> {
    let s_binary = s
        .chars()
        .flat_map(|c| {
            format!("{:04b}", u64::from_str_radix(&c.to_string(), 16).unwrap())
                .chars()
                .collect_vec()
        })
        .collect::<String>();

    Ok(add_versions(&parse_packet(&mut s_binary.chars())?))
}

fn part_2(s: &str) -> Result<u64> {
    let s_binary = s
        .chars()
        .flat_map(|c| {
            format!("{:04b}", u64::from_str_radix(&c.to_string(), 16).unwrap())
                .chars()
                .collect_vec()
        })
        .collect::<String>();

    let packet = parse_packet(&mut s_binary.chars())?;
    dbg!(&packet);

    Ok(packet.eval())
}

fn main() -> Result<()> {
    println!(
        "Part 1 (821) {:?}",
        part_1(include_str!("../data/16.input").trim())?
    );

    println!(
        "Part 2 {}",
        part_2(include_str!("../data/16.input").trim())?
    );

    Ok(())
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_multiply() {
        assert_eq!(54, part_2("04005AC33890").unwrap());
    }

    #[test]
    fn test_minimum() {
        assert_eq!(7, part_2("880086C3E88112").unwrap());
    }

    #[test]
    fn test_maximum() {
        assert_eq!(9, part_2("CE00C43D881120").unwrap());
    }

    #[test]
    fn test_gt() {
        assert_eq!(0, part_2("F600BC2D8F").unwrap());
    }

    #[test]
    fn test_lt() {
        assert_eq!(1, part_2("D8005AC2A8F0").unwrap());
    }

    #[test]
    fn test_eq() {
        assert_eq!(0, part_2("9C005AC2F8F0").unwrap());
    }

    #[test]
    fn test_eq_rec() {
        assert_eq!(1, part_2("9C0141080250320F1802104A08").unwrap());
    }
}
