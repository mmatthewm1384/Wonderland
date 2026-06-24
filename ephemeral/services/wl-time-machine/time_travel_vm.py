import datetime
import json
import os
import random
import time
import sys
from collections import defaultdict

class TemporalVM:
    def __init__(self):
        self.current_time = datetime.datetime.now()
        self.timeline = []  # List of events
        self.branches = defaultdict(list)  # Alternate timelines
        self.anchor_reality()  # Tie to real world
        
    def anchor_reality(self):
        """Anchor to current reality"""
        self.timeline.append({
            "timestamp": self.current_time.isoformat(),
            "event": "Reality Anchor - You are here now",
            "delta": 0
        })
        print(f"🕒 Temporal Core initialized in reality at {self.current_time}")
    
    def travel(self, years=0, months=0, days=0, hours=0, minutes=0, seconds=0, branch_name=None):
        delta = datetime.timedelta(days=days + 30*months + 365*years, 
                                 hours=hours, minutes=minutes, seconds=seconds)
        new_time = self.current_time + delta
        
        event = {
            "timestamp": new_time.isoformat(),
            "event": f"Time jump of {years}y {months}m {days}d {hours}h {minutes}m {seconds}s",
            "delta": delta.total_seconds()
        }
        
        if branch_name:
            self.branches[branch_name].append(event)
            print(f"🌌 Branched into timeline '{branch_name}'")
        else:
            self.timeline.append(event)
        
        self.current_time = new_time
        print(f"✅ Traveled to: {new_time.strftime('%Y-%m-%d %H:%M:%S')} UTC")
        self.observe()
    
    def observe(self):
        """Observe current 'reality'"""
        print(f"\n📡 Current Temporal State:")
        print(f"   Time: {self.current_time}")
        print(f"   Events logged: {len(self.timeline) + sum(len(b) for b in self.branches.values())}")
        if random.random() < 0.3:
            print("   🌟 Butterfly Effect: A small change ripples... (random event)")
    
    def log_event(self, description):
        """Log a real-world event"""
        event = {
            "timestamp": datetime.datetime.now().isoformat(),
            "event": description,
            "delta": 0
        }
        self.timeline.append(event)
        print(f"📝 Reality Event Logged: {description}")
    
    def view_timeline(self):
        print("\n📜 Main Timeline:")
        for e in self.timeline[-10:]:  # Last 10
            print(f"  {e['timestamp'][:19]} | {e['event']}")
        
        if self.branches:
            print("\n🌳 Alternate Branches:")
            for name, events in list(self.branches.items())[-3:]:
                print(f"  Branch '{name}': {len(events)} events")
    
    def save_session(self):
        data = {
            "current_time": self.current_time.isoformat(),
            "timeline": self.timeline,
            "branches": dict(self.branches)
        }
        with open("temporal_save.json", "w") as f:
            json.dump(data, f, indent=2)
        print("💾 Session saved to temporal_save.json")
    
    def load_session(self):
        if os.path.exists("temporal_save.json"):
            with open("temporal_save.json") as f:
                data = json.load(f)
            self.current_time = datetime.datetime.fromisoformat(data["current_time"])
            self.timeline = data["timeline"]
            self.branches = defaultdict(list, data["branches"])
            print("🔄 Session restored from saved reality")
        else:
            print("No previous timeline found.")

def main():
    vm = TemporalVM()
    print("\n" + "="*60)
    print("🌀 TEMPORAL VM v1.0 - Time Travel Simulator")
    print("   Works inside reality • Persistent across runs")
    print("="*60)
    
    while True:
        print("\nCommands: travel | observe | log | timeline | branch | save | load | exit")
        cmd = input("🕒 > ").strip().lower()
        
        if cmd.startswith("travel"):
            try:
                parts = cmd.split()[1:]
                kwargs = {}
                for p in parts:
                    if p.endswith('y'): kwargs['years'] = int(p[:-1])
                    elif p.endswith('m'): kwargs['months'] = int(p[:-1])
                    elif p.endswith('d'): kwargs['days'] = int(p[:-1])
                    elif p.endswith('h'): kwargs['hours'] = int(p[:-1])
                vm.travel(**kwargs)
            except:
                print("Usage: travel 5y 3m 10d (or any combo)")
        
        elif cmd == "observe":
            vm.observe()
        elif cmd.startswith("log "):
            vm.log_event(cmd[4:])
        elif cmd == "timeline":
            vm.view_timeline()
        elif cmd.startswith("branch"):
            name = cmd.split()[1] if len(cmd.split()) > 1 else "alt-" + str(random.randint(1000,9999))
            vm.travel(0, branch_name=name)
        elif cmd == "save":
            vm.save_session()
        elif cmd == "load":
            vm.load_session()
        elif cmd == "exit":
            print("🌀 Temporal Core shutting down. Reality preserved.")
            break
        else:
            print("Unknown command. Try: travel 10y")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nTime travel interrupted. See you in another timeline!")
