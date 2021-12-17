use std::collections::{HashMap, HashSet};

#[derive(Debug, Clone)]
struct Node {
    big: bool,
    name: String,
    conn: HashSet<String>,
}

fn add_node(nodes: &mut HashMap<String, Node>, item: &str) {
    if !nodes.contains_key(item) {
        nodes.insert(
            item.to_string(),
            Node {
                big: item.chars().next().unwrap().is_uppercase(),
                name: item.to_string(),
                conn: HashSet::new(),
            },
        );
    }
}

fn connect_node(nodes: &mut HashMap<String, Node>, left: &str, right: &str) {
    nodes.get_mut(left).unwrap().conn.insert(right.to_string());
    nodes.get_mut(right).unwrap().conn.insert(left.to_string());
}

#[derive(Debug, Clone)]
struct Sightings {
    max_count: u32,
    max_key: Option<String>,
    counts: HashMap<String, u32>,
}

impl Sightings {
    fn can_visit(&self, node: &Node) -> bool {
        if node.big {
            true
        } else {
            if node.name == "start" {
                return false;
            }

            let count = *self.counts.get(&node.name).unwrap_or(&0);
            match &self.max_key {
                Some(key) => count == 0 || (key == &node.name && count < self.max_count),
                None => count <= self.max_count - 1,
            }
        }
    }

    fn visit(&mut self, node: &Node) {
        let val = *self.counts.get(&node.name).unwrap_or(&0) + 1;
        if !node.big && val > 1 && self.max_key == None {
            self.max_key = Some(node.name.to_string());
        }

        self.counts.insert(node.name.clone(), val);
    }
}

fn find_path(
    nodes: &HashMap<String, Node>,
    start: &Node,
    path: &mut Vec<String>,
    sightings: &mut Sightings,
) -> Vec<Vec<String>> {
    let mut paths = vec![];
    sightings.visit(start);

    for conn in start.conn.iter() {
        let mut conn_path = path.clone();
        conn_path.push(conn.to_string());

        let conn_node = nodes.get(conn).unwrap();

        if conn == "end" {
            paths.push(conn_path);
            continue;
        }

        if !sightings.can_visit(&conn_node) {
            continue;
        }

        let mut conn_sightings = sightings.clone();
        paths.append(&mut find_path(
            nodes,
            &conn_node,
            &mut conn_path,
            &mut conn_sightings,
        ));
    }

    return paths;
}

fn main() {
    let mut nodes = HashMap::new();

    let _ = include_str!("../data/12.input")
        .lines()
        .map(|l| l.split_once("-").unwrap())
        .for_each(|(left, right)| {
            add_node(&mut nodes, left);
            add_node(&mut nodes, right);

            connect_node(&mut nodes, left, right);
        });

    println!("{:?}", nodes);

    let start = nodes.get("start").unwrap().clone();
    let mut sightings = Sightings {
        max_count: 2,
        max_key: None,
        counts: HashMap::new(),
    };
    println!(
        "find_path(&mut nodes): {:?}",
        find_path(
            &nodes,
            &start,
            &mut vec!["start".to_string()],
            &mut sightings
        )
        .len()
    );

    // Can't you do something where you're workin backwards from `end` and then you
    // memoize the results and then append those to the list or something?
}
