import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/* Eight Threads, Shared Data, Using Locks
 * ThreadData
 * CS 485
 * Jason Bendickson
 */
public class ThreadData {
	//variables
	private int counter;
	private String threadName = null;
	private Lock lock = new ReentrantLock();
	
	//constructor
	public ThreadData(String threadName) {
		this.threadName = threadName;
		counter = 0;
		this.lock = lock;
	}
	
	public String getThreadName() {return threadName; }	
	public synchronized int getCount() { return counter; }
	public void tdCounter() {
		lock.lock(); 
		try {
			counter++;
		}
		finally {
			lock.unlock();;
		}
	}
	
}
