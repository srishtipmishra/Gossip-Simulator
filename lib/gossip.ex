defmodule Gossip do
  use GenServer
  
  def start_link(node_number,counter) do
        {:ok,initial_state} = GenServer.start_link(__MODULE__,[node_number,counter], name: :"#{node_number}") 
    end

    def gossip(my_node,num_nodes,topology,start_time) do
        pid = GenServer.whereis(:"#{my_node}")
        GenServer.cast(pid, {:gossip,my_node,num_nodes,topology,start_time})
    end

    def init(intial_data) do
        {:ok,intial_data}
    end

    def handle_cast({:gossip,my_node,num_nodes, topology,start_time}, [h|t]) do
        new_state = []
        counter = t
        if counter < 10 do
             
            case topology do
                "full" ->
                    neighbor = Push_Sum.find_neighbors_full(num_nodes,my_node)
                "2D" ->
                    neighbor = Push_Sum.find_neighbor_2D(num_nodes,my_node,topology)
                "imp2D" ->
                    neighbor = Push_Sum.find_neighbor_2D(num_nodes,my_node,topology)
                "line" -> 
                    neighbor = Push_Sum.find_neighbors_line(num_nodes,my_node)
            end 
            #[h|t] = neighbor
            new_state = [my_node,counter+1]
            gossip(neighbor,num_nodes,topology,start_time)
            {:noreply,new_state}
        
    else
        end_time = DateTime.utc_now() 
        time_taken = DateTime.diff(end_time,start_time,:millisecond)
        {:noreply,[h|t]}
end
    end
end

