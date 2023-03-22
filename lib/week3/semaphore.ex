defmodule Semaphore do
  def createSemaphore() do
    spawn(Semaphore, :semaphore, [[], 0, 1])
  end

  def semaphore(tasklist, size, maxSize) do
    receive do
      {:acquire, task} ->
        if(maxSize - size >= 1 ) do
          #If size permits, give task an ok
          send(task, :ok)
          semaphore(tasklist, size + 1, maxSize)
        else
          #If not add task to queue
          send(task, :no)
          semaphore(List.insert_at(tasklist, -1, task), size, maxSize)
        end

        {:release, _task} ->
          #If there are tasks waiting for their turn
          if(length(tasklist)>0) do
            #Get first out of queue. Send it ok message and renew semaphore
            first = List.first(tasklist)
            new_list = List.delete_at(tasklist, 0)
            send(first, :ok)
            semaphore(new_list, size, maxSize)
          else
            #If no one waiting just decrement size
            semaphore(tasklist, size-1, maxSize)
          end
    end
    semaphore(tasklist, size, maxSize)
  end

  def acquire(pid) do
    send(pid, {:acquire, self()})

    res = fn -> receive do
      :ok ->
        true
      end
    end
    #task should be waiting indefinitely till ok is received
    res.()
  end

  def release(pid) do
    send(pid, {:release, self()})
  end

end
