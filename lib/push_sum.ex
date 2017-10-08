defmodule  Push_Sum do
    use GenServer

    def start_link(node_number,w,counter) do
        {:ok,initial_state} = GenServer.start_link(Push_Sum,[node_number,w,counter,node_number], name: :"#{node_number}")
    end

    def init(initial_data) do
        #state = []
        initial_state = initial_data
        {:ok,initial_state}
    end

    def push_sum(node_number,s,w,topology,num_nodes,start_time) do
        pid = GenServer.whereis(:"#{node_number}")
        GenServer.cast(pid, {:receive_sum,s,w,topology, num_nodes,start_time})
    end

    def handle_cast({:receive_sum,s,w,topology,num_nodes,start_time}, [h|t]) do
        #initial_state = initial_state ++ state
        old_s = h
        [old_w|tail] = t
        [counter|tail2] = tail
        [my_name|tail3] = tail2
        new_s = s + old_s
        new_w = w + old_w

        old_ratio = old_s/old_w
        new_ratio = new_s/new_w
        ratio_diff = if old_ratio > new_ratio do old_ratio-new_ratio else new_ratio-old_ratio end 
        if :math.pow(10,-10) < ratio_diff do
            case topology do
                    "full" ->
                        neighbor = find_neighbors_full(num_nodes,my_name)
                    "2D" ->
                        neighbor = find_neighbor_2D(num_nodes,my_name,"2D")
                    "imp2D" ->
                        neighbor = find_neighbor_2D(num_nodes,my_name,"imp2D")
                    "line" -> 
                        neighbor = find_neighbors_line(num_nodes,my_name)
            end 
            new_state = [new_s/2, new_w/2, 0, my_name]
            #IO.inspect new_state
            push_sum(neighbor,new_s/2,new_w/2,topology,num_nodes,start_time)
            {:noreply,new_state}
        else 
            if counter >= 3 do flag = true else flag = false end
            case flag do
                true -> end_time = DateTime.utc_now() 
                        time_taken = DateTime.diff(end_time,start_time,:millisecond)
                        {:noreply,[h|t]}
                false -> 
                    case topology do
                    "full" ->
                        neighbor = find_neighbors_full(num_nodes,my_name)
                    "2D" ->
                        neighbor = find_neighbor_2D(num_nodes,my_name,"2D")
                    "imp2D" ->
                        neighbor = neighbor = find_neighbor_2D(num_nodes,my_name,"imp2D")
                    "line" -> 
                        neighbor = find_neighbors_line(num_nodes,my_name)
                    end 
                    new_state = [new_s/2,new_w/2,counter+1,my_name]
                    #IO.inspect new_state
                    push_sum(neighbor,new_s/2,new_w/2,topology,num_nodes,start_time)
                    {:noreply,new_state}
            end
        end
    end

    def find_neighbors_full(num_nodes,my_node) do
        neighbor_list = []
        node_list = Enum.to_list(1..num_nodes)
        #IO.inspect node_list
        neighbor_list = neighbor_list ++ Enum.filter node_list, fn node -> node != my_node end
        neighbor = Enum.random(neighbor_list)
    end

    def find_neighbors_line(num_nodes, my_node) do
        neighbor_list = []
        if my_node == 1 do neighbor = 2 end
        if my_node == num_nodes do 
            neighbor = num_nodes-1 
        else 
            
            neighbor_list = [my_node-1,my_node+1]
            neighbor = Enum.random(neighbor_list)
            IO.puts neighbor
        end
    end

    def find_neighbor_2D(num_nodes, my_node,topology) do
        grid_size = round(:math.sqrt(num_nodes))
        if my_node <= 10 do
            [x,y] = [1,my_node]
        end
        if my_node == num_nodes do
            [x,y] = [grid_size,grid_size]
        else
            div_val = div(my_node,grid_size)
            rem_val = rem(my_node,grid_size)
            if rem_val != 0 do
                div_val = div_val+ 1
            else
                rem_val = grid_size
            end
            [x,y] = [div_val,rem_val]
        end

        [t,b] = 
        case x do
          1 -> [grid_size, 2] 
          ^grid_size -> [grid_size-1, 1]
          _ -> [x-1, x+1]
        end  

        [l,r] = 
        case y do
          1 -> [grid_size, 2] 
          ^grid_size -> [grid_size-1, 1]
          _ -> [y-1, y+1]
        end

        #neighbor_list = [l,r,t,b]
        node1 = ((x-1)*grid_size)+l
        node2 = ((x-1)*grid_size+r)
        node3 = ((t-1)*grid_size+y)
        node4 = ((b-1)*grid_size+y)
        
        neighbor_list =  [node1 , node2, node3, node4]
        if topology == "imp2D" do
            node_list = Enum.to_list(1..num_nodes)
            neighbor_list = neighbor_list ++ [Enum.random(node_list)]
            neighbor = Enum.random(neighbor_list)
        else
            neighbor = Enum.random(neighbor_list)
        end
    end   
end
