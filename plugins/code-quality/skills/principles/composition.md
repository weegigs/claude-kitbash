---
name: composition
description: Prefer composition over inheritance.
---

# Prefer Composition Over Inheritance

Build complex behavior by combining simple, focused pieces rather than deep inheritance hierarchies.

## TypeScript

### ❌ Don't: Deep inheritance hierarchies

```typescript
class Animal {
  move() {
    console.log("Moving...");
  }
}

class Bird extends Animal {
  fly() {
    console.log("Flying...");
  }
}

class Penguin extends Bird {
  // Problem: Penguin inherits fly() but can't fly
  // We'd need to override with a no-op or throw
  fly() {
    throw new Error("Penguins can't fly!");
  }

  swim() {
    console.log("Swimming...");
  }
}

// Fragile base class problem: changes to Animal affect all descendants
// Diamond problem potential with multiple inheritance
```

### ✅ Do: Compose behaviors

```typescript
// Define capabilities as independent functions
const withMovement = <T extends object>(entity: T) => ({
  ...entity,
  move: () => console.log("Moving..."),
});

const withFlight = <T extends object>(entity: T) => ({
  ...entity,
  fly: () => console.log("Flying..."),
});

const withSwimming = <T extends object>(entity: T) => ({
  ...entity,
  swim: () => console.log("Swimming..."),
});

// Compose only what's needed
const sparrow = withFlight(withMovement({ name: "Sparrow" }));
const penguin = withSwimming(withMovement({ name: "Penguin" }));

sparrow.fly(); // Works
penguin.swim(); // Works
// penguin.fly(); // Compile error—penguins don't have fly()
```

### ✅ Do: Use interfaces for contracts

```typescript
interface Movable {
  move(): void;
}

interface Flyable {
  fly(): void;
}

interface Swimmable {
  swim(): void;
}

// Implement only what applies
class Sparrow implements Movable, Flyable {
  move() { console.log("Hopping..."); }
  fly() { console.log("Flying..."); }
}

class Penguin implements Movable, Swimmable {
  move() { console.log("Waddling..."); }
  swim() { console.log("Swimming..."); }
}
```

## Rust

### ❌ Don't: Force inheritance-like patterns

```rust
// Rust doesn't have inheritance, but people try to simulate it poorly
trait Animal {
    fn move_around(&self);
    fn fly(&self); // Not all animals fly!
    fn swim(&self); // Not all animals swim!
}

struct Sparrow;
struct Penguin;

impl Animal for Sparrow {
    fn move_around(&self) { println!("Hopping"); }
    fn fly(&self) { println!("Flying"); }
    fn swim(&self) { panic!("Sparrows don't swim!"); } // Forced to implement
}

impl Animal for Penguin {
    fn move_around(&self) { println!("Waddling"); }
    fn fly(&self) { panic!("Penguins don't fly!"); } // Forced to implement
    fn swim(&self) { println!("Swimming"); }
}
```

### ✅ Do: Compose with traits

```rust
// Define capabilities as separate traits
trait Movable {
    fn move_around(&self);
}

trait Flyable {
    fn fly(&self);
}

trait Swimmable {
    fn swim(&self);
}

struct Sparrow;
struct Penguin;

// Implement only what applies
impl Movable for Sparrow {
    fn move_around(&self) { println!("Hopping"); }
}

impl Flyable for Sparrow {
    fn fly(&self) { println!("Flying"); }
}

impl Movable for Penguin {
    fn move_around(&self) { println!("Waddling"); }
}

impl Swimmable for Penguin {
    fn swim(&self) { println!("Swimming"); }
}

// Functions accept only what they need
fn make_fly(flyer: &impl Flyable) {
    flyer.fly();
}

fn make_swim(swimmer: &impl Swimmable) {
    swimmer.swim();
}
```

### ✅ Do: Compose with structs

```rust
// Behavior as data
struct Movement {
    style: String,
}

impl Movement {
    fn execute(&self) {
        println!("{}", self.style);
    }
}

struct Flight {
    altitude: u32,
}

impl Flight {
    fn execute(&self) {
        println!("Flying at {} feet", self.altitude);
    }
}

// Compose behaviors
struct Bird {
    name: String,
    movement: Movement,
    flight: Option<Flight>, // Not all birds fly
}

let sparrow = Bird {
    name: "Sparrow".into(),
    movement: Movement { style: "Hopping".into() },
    flight: Some(Flight { altitude: 100 }),
};

let penguin = Bird {
    name: "Penguin".into(),
    movement: Movement { style: "Waddling".into() },
    flight: None, // Penguins don't fly
};
```

## When to Apply

Look for these patterns that indicate inheritance is being misused:

- Base classes with methods not all subclasses need
- "Is-a" relationships that are actually "has-a"
- Deep inheritance trees (more than 2-3 levels)
- Overridden methods that throw `NotImplemented` or do nothing
- Changes to base class breaking multiple subclasses
